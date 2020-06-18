import 'dart:async';

import 'package:angel_framework/angel_framework.dart' as angel;
import 'package:angel_framework/http.dart';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

import './HttpResponseSender.dart';
import '../connect/HttpConnectionResolver.dart';
import './IRegisterable.dart';

/// Used for creating HTTP endpoints. An endpoint is a URL, at which a given service can be accessed by a client.
///
/// ### Configuration parameters ###
///
/// Parameters to pass to the [[configure]] method for component configuration:
///
/// - [connection](s) - the connection resolver's connections:
///     - '[connection.discovery_key]' - the key to use for connection resolving in a discovery service;
///     - '[connection.protocol]' - the connection's protocol;
///     - '[connection.host]' - the target host;
///     - '[connection.port]' - the target port;
///     - '[connection.uri]' - the target URI.
/// - [credential] - the HTTPS credentials:
///     - '[credential.ssl_key_fil]e' - the SSL private key in PEM
///     - '[credential.ssl_crt_file]' - the SSL certificate in PEM
///     - '[credential.ssl_ca_file]' - the certificate authorities (root cerfiticates) in PEM
///
/// ### References ###
///
/// A logger, counters, and a connection resolver can be referenced by passing the
/// following references to the object's [[setReferences]] method:
///
/// - logger: ['\*:logger:\*:\*:1.0'];
/// - counters: ['\*:counters:\*:\*:1.0'];
/// - discovery: ['\*:discovery:\*:\*:1.0'] (for the connection resolver).
///
/// ### Examples ###
///
///     public MyMethod(ConfigParams _config, IReferences _references) {
///         var endpoint = HttpEndpoint();
///         if (config != null)
///             endpoint.configure(_config);
///         if (references)
///             endpoint.setReferences(references);
///         ...
///
///         _endpoint.open(correlationId)
///         _opened = true;
///
///         ...
///     }

class HttpEndpoint implements IOpenable, IConfigurable, IReferenceable {
  static final _defaultConfig = ConfigParams.fromTuples([
    'connection.protocol',
    'http',
    'connection.host',
    '0.0.0.0',
    'connection.port',
    3000,
    'credential.ssl_key_file',
    null,
    'credential.ssl_crt_file',
    null,
    'credential.ssl_ca_file',
    null,
    'options.maintenance_enabled',
    false,
    'options.request_max_size',
    1024 * 1024,
    'options.file_max_size',
    200 * 1024 * 1024,
    'options.connect_timeout',
    60000,
    'options.debug',
    true
  ]);

  AngelHttp _server;
  angel.Angel _app;
  final _middleware = <angel.RequestHandler>[];
  final _connectionResolver = HttpConnectionResolver();
  final _logger = CompositeLogger();
  final _counters = CompositeCounters();
  bool _maintenanceEnabled = false;
  int _fileMaxSize = 200 * 1024 * 1024;
  bool _protocolUpgradeEnabled = false;
  String _uri;
  final _registrations = <IRegisterable>[];

  /// Configures this HttpEndpoint using the given configuration parameters.
  ///
  /// [Configuration parameters:]
  /// - [connection(s)] - the connection resolver's connections;
  ///     - '[connection.discovery_key]' - the key to use for connection resolving in a discovery service;
  ///     - '[connection.protocol]' - the connection's protocol;
  ///     - '[connection.host]' - the target host;
  ///     - '[connection.port]' - the target port;
  ///     - '[connection.uri]' - the target URI.
  ///     - '[credential.ssl_key_file]' - SSL private key in PEM
  ///     - '[credential.ssl_crt_file]' - SSL certificate in PEM
  ///     - '[credential.ssl_ca_file]' - Certificate authority (root certificate) in PEM
  ///
  /// - [config]    configuration parameters, containing a 'connection(s)' section.
  ///
  /// See [ConfigParams] (in the PipServices 'Commons' package)

  @override
  void configure(ConfigParams config) {
    config = config.setDefaults(HttpEndpoint._defaultConfig);
    _connectionResolver.configure(config);

    _maintenanceEnabled = config.getAsBooleanWithDefault(
        'options.maintenance_enabled', _maintenanceEnabled);
    _fileMaxSize =
        config.getAsLongWithDefault('options.file_max_size', _fileMaxSize);
    _protocolUpgradeEnabled = config.getAsBooleanWithDefault(
        'options.protocol_upgrade_enabled', _protocolUpgradeEnabled);
  }

  /// Sets references to this endpoint's logger, counters, and connection resolver.
  ///
  /// [References:[
  /// - logger: ['\*:logger:\*:\*:1.0']
  /// - counters: ['\*:counters:\*:\*:1.0']
  /// - discovery: ['\*:discovery:\*:\*:1.0'] (for the connection resolver)
  ///
  /// - references    an IReferences object, containing references to a logger, counters,
  ///                      and a connection resolver.
  ///
  /// See [IReferences] (in the PipServices 'Commons' package)
  @override
  void setReferences(IReferences references) {
    _logger.setReferences(references);
    _counters.setReferences(references);
    _connectionResolver.setReferences(references);
  }

  /// Returns whether or not this endpoint is open with an actively listening REST server.
  @override
  bool isOpen() {
    return _server != null;
  }

  /// Opens a connection using the parameters resolved by the referenced connection
  /// resolver and creates a REST server (service) using the set options and parameters.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// Return              Future when the opening process is complete.
  ///                     Will be called with an error if one is raised.
  @override
  Future open(String correlationId) async {
    if (isOpen()) {
      return null;
    }

    var connection = await _connectionResolver.resolve(correlationId);

    _uri = connection.getUri();
    try {
      _app = angel.Angel();

      if (connection.getProtocol('http') == 'https') {
        var sslKeyFile = connection.getAsNullableString('ssl_key_file');
        var sslCrtFile = connection.getAsNullableString('ssl_crt_file');
        _server = AngelHttp.secure(_app, sslCrtFile, sslKeyFile);
      } else {
        _server = AngelHttp(_app);
      }

      _middleware.add(_addCors);
      _middleware.add(_addCompatibility);
      _middleware.add(_noCache);
      _middleware.add(_doMaintenance);

      _performRegistrations();
      await _server.startServer(connection.getHost(), connection.getPort());
      await _connectionResolver.register(correlationId);
      _logger.debug(correlationId, 'Opened REST service at %s', [_uri]);
    } catch (ex) {
      _server = null;
      _app = null;

      print(ex);

      var err = ConnectionException(
              correlationId, 'CANNOT_CONNECT', 'Opening REST service failed')
          .wrap(ex)
          .withDetails('url', _uri);
      throw err;
    }
  }

  Future _addCors(angel.RequestContext req, angel.ResponseContext res) async {
    res.headers.addAll(<String, String>{
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT, DELETE',
      'Access-Control-Allow-Headers':
          'Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization'
    });
    return true;
  }

  Future _addCompatibility(
      angel.RequestContext req, angel.ResponseContext res) async {
    // TODO: need write the method
    // req.param = (name) => {
    //     if (req.query) {
    //         var param = req.query[name];
    //         if (param) return param;
    //     }
    //     if (req.body) {
    //         var param = req.body[name];
    //         if (param) return param;
    //     }
    //     if (req.params) {
    //         var param = req.params[name];
    //         if (param) return param;
    //     }
    //     return null;
    // }

    // req.route.params = req.params;
    return true;
  }

  // Prevents IE from caching REST requests
  Future _noCache(angel.RequestContext req, angel.ResponseContext res) async {
    var headers = <String, String>{
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    };
    res.headers.addAll(headers);
    return true;
  }

  // Returns maintenance error code
  Future _doMaintenance(
      angel.RequestContext req, angel.ResponseContext res) async {
    // Make this more sophisticated
    if (_maintenanceEnabled) {
      res.headers.addAll({'Retry-After': '3600'});
      res.json(503);
    }
    return true;
  }

  /// Closes this endpoint and the REST server (service) that was opened earlier.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// Return              once the closing process is complete.
  ///                     Will be called with an error if one is raised.
  @override
  Future close(String correlationId) async {
    if (_server != null) {
      // Eat exceptions
      try {
        await _server.close();
        await _app.close();

        _logger.debug(correlationId, 'Closed REST service at %s', [_uri]);
      } catch (ex) {
        _logger.warn(
            correlationId, 'Failed while closing REST service: %s', ex);
        rethrow;
      }
      _middleware.remove(_addCors);
      _middleware.remove(_addCompatibility);
      _middleware.remove(_noCache);
      _middleware.remove(_doMaintenance);
      _server = null;
      _app = null;
      _uri = null;
    }
  }

  /// Registers a registerable object for dynamic endpoint discovery.
  ///
  /// - [registration]      the IRegisterable registration to add.
  ///
  /// See [[IRegisterable]]
  void register(IRegisterable registration) {
    _registrations.add(registration);
  }

  /// Unregisters a registerable object, so that it is no longer used in dynamic
  /// endpoint discovery.
  ///
  /// - [registration]      the IRegisterable registration to remove.
  ///
  /// See [[IRegisterable]]
  void unregister(IRegisterable registration) {
    _registrations.remove(registration);
  }

  void _performRegistrations() {
    for (var registration in _registrations) {
      registration.register();
    }
  }

  String _fixRoute(String route) {
    if (route != null && route.isNotEmpty && !route.startsWith('/')) {
      route = '/' + route;
    }
    return route;
  }

  /// Registers an action in this objects REST server (service) by the given method and route.
  ///
  /// - [method]        the HTTP method of the route.
  /// - [route]         the route to register in this object's REST server (service).
  /// - [schema]        the schema to use for parameter validation.
  /// - [action]        the action to perform at the given route.
  void registerRoute(String method, String route, Schema schema,
      action(angel.RequestContext req, angel.ResponseContext res)) {
    if (_app == null) {
      throw ApplicationException('', 'NOT_OPENED', 'Can\'t add route');
    }

    method = method.toUpperCase();
    if (method == 'DEL') method = 'DELETE';

    route = _fixRoute(route);

    var actionCurl =
        (angel.RequestContext req, angel.ResponseContext res) async {
      // Perform validation
      if (schema != null) {
        var params = req.params;
        params.addAll(req.queryParameters);
        if (req.contentType != null) {
          await req.parseBody();
          var body = req.bodyAsMap;
          params['body'] = body;
        }

        var correlationId = params['correlaton_id'];
        var err =
            schema.validateAndReturnException(correlationId, params, false);
        if (err != null) {
          HttpResponseSender.sendError(req, res, err);
          return;
        }
      }
      await action(req, res);
    };
    _app.addRoute(method, route, actionCurl, middleware: _middleware);
  }

  /// Registers an action with authorization in this objects REST server (service)
  /// by the given method and route.
  ///
  /// - [method]        the HTTP method of the route.
  /// - [route]         the route to register in this object's REST server (service).
  /// - [schema]        the schema to use for parameter validation.
  /// - [authorize]     the authorization interceptor
  /// - [action]        the action to perform at the given route.
  void registerRouteWithAuth(
      String method,
      String route,
      Schema schema,
      authorize(angel.RequestContext req, angel.ResponseContext res, next()),
      action(angel.RequestContext req, angel.ResponseContext res)) {
    if (authorize != null) {
      var nextAction = action;
      action = (req, res) async {
        await authorize(req, res, () async {
          await nextAction(req, res);
        });
      };
    }

    registerRoute(method, route, schema, action);
  }

  /// Registers a middleware action for the given route.
  ///
  /// - [route]         the route to register in this object's REST server (service).
  /// - [action]        the middleware action to perform at the given route.
  void registerInterceptor(String route,
      Future action(angel.RequestContext req, angel.ResponseContext res)) {
    route = _fixRoute(route);

    _middleware
        .add((angel.RequestContext req, angel.ResponseContext res) async {
      if (route != null && route != '' && !req.uri.path.startsWith(route)) {
        return true;
      } else {
        return action(req, res);
      }
    });
  }
}

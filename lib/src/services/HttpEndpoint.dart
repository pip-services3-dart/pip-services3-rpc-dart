import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:cli';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

import './HttpResponseSender.dart';
import '../connect/HttpConnectionResolver.dart';
import './IRegisterable.dart';

/// Used for creating HTTP endpoints. An endpoint is a URL, at which a given service can be accessed by a client.
///
/// ### Configuration parameters ###
///
/// Parameters to pass to the [configure] method for component configuration:
///
/// - [cors_headers] - a comma-separated list of allowed CORS headers
/// - [cors_origins] - a comma-separated list of allowed CORS origins
///
/// - [cors_headers] - a comma-separated list of allowed CORS headers
/// - [cors_origins] - a comma-separated list of allowed CORS origins
/// - [connection(s)] - the connection resolver's connections:
///     - '[connection.discovery_key]' - the key to use for connection resolving in a discovery service;
///     - '[connection.protocol]' - the connection's protocol;
///     - '[connection.host]' - the target host;
///     - '[connection.port]' - the target port;
///     - '[connection.uri]' - the target URI.
/// - [credential] - the HTTPS credentials:
///     - '[credential.ssl_key_file]' - the SSL private key in PEM
///     - '[credential.ssl_crt_file]' - the SSL certificate in PEM
///     - '[credential.ssl_ca_file]' - the certificate authorities (root cerfiticates) in PEM
///
/// ### References ###
///
/// A logger, counters, and a connection resolver can be referenced by passing the
/// following references to the object's [setReferences] method:
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

  HttpServer? _server; // = shelf_io.serve((request) => null, address, port);
  Router? _app;
  final _connectionResolver = HttpConnectionResolver();
  final _logger = CompositeLogger();
  final _counters = CompositeCounters();
  bool _maintenanceEnabled = false;
  int _fileMaxSize = 200 * 1024 * 1024;
  bool _protocolUpgradeEnabled = false;
  String? _uri;
  final _registrations = <IRegisterable>[];
  List<String> _allowedHeaders = ['correlation_id'];
  List<String> _allowedOrigins = [];

  final List<Future<Request?> Function(Request req)> _interceptors = [];

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
  /// See [ConfigParams](https://pub.dev/documentation/pip_services3_commons/latest/pip_services3_commons/ConfigParams-class.html) (in the PipServices 'Commons' package)

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

    var headers = config.getAsStringWithDefault('cors_headers', '').split(',');
    for (var header in headers) {
      header = header.trim();
      if (header != '') {
        _allowedHeaders = _allowedHeaders.where((h) => h != header).toList();
        _allowedHeaders.add(header);
      }
    }

    var origins = config.getAsStringWithDefault('cors_origins', '').split(',');
    for (var origin in origins) {
      origin = origin.trim();
      if (origin != '') {
        _allowedOrigins = _allowedOrigins.where((h) => h != origin).toList();
        _allowedOrigins.add(origin);
      }
    }
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
  /// See [IReferences](https://pub.dev/documentation/pip_services3_commons/latest/pip_services3_commons/IReferences-class.html) (in the PipServices 'Commons' package)
  @override
  void setReferences(IReferences references) {
    _logger.setReferences(references);
    _counters.setReferences(references);
    _connectionResolver.setReferences(references);
  }

  /// Gets an HTTP server instance.
  /// Returns an HTTP server instance of <code>null</code> if endpoint is closed.
  HttpServer? getServer() {
    return _server;
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
  Future open(String? correlationId) async {
    if (isOpen()) {
      return null;
    }

    var connection = await _connectionResolver.resolve(correlationId);

    _uri = connection?.getAsString('uri');
    var host = connection!.getAsString('host');
    var port = connection.getAsInteger('port');
    try {
      _app = Router();

      var startServer;

      var serverContext;

      if (connection.getAsStringWithDefault('protocol', 'http') == 'https') {
        var sslKeyFile = connection.getAsString('ssl_key_file');
        var sslCrtFile = connection.getAsString('ssl_crt_file');

        var certificateChain = Platform.script.resolve(sslCrtFile).toFilePath();
        var serverKey = Platform.script.resolve(sslKeyFile).toFilePath();
        serverContext = SecurityContext();
        serverContext.useCertificateChain(certificateChain);
        serverContext.usePrivateKey(serverKey);

        // todo add ssl_ca_file
      }

      startServer = () async {
        _server = await shelf_io.serve(
            Pipeline().addMiddleware(_handler()).addHandler(_app!), host, port,
            securityContext: serverContext);
      };

      _performRegistrations();
      await startServer();
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

  /// request handler
  Middleware _handler() => (innerHandler) {
        return (request) {
          // execute before request
          request = waitFor(_noCache(request));
          request = waitFor(_addCompatibility(request));

          // apply interceptors
          _interceptors.forEach((interseptor) {
            request = waitFor(interseptor(request)) ?? request;
            // request = await interseptor(request) ?? request;
          });

          return Future.sync(() => innerHandler(request)).then((response) {
            // execute after request
            response = waitFor(_addCors(response));
            response = waitFor(_doMaintenance(response));

            return response;
          }, onError: (Object error, StackTrace stackTrace) {
            // execute if error
            if (error is HijackException) throw error;
          });
        };
      };

  Future<Response> _addCors(Response res) async {
    // Configure CORS requests
    var origins = _allowedOrigins;
    if (origins.isEmpty) {
      origins = ['*'];
    }

    res = res.change(headers: <String, String>{
      'Access-Control-Allow-Origin': origins.join(', '),
      'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT, DELETE',
      'Access-Control-Expose-Headers': _allowedHeaders.join(', '),
      'Access-Control-Allow-Headers': _allowedHeaders.join(', ')
    });

    return res;
  }

  Future<Request> _addCompatibility(Request req) async {
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
    return req;
  }

  // Prevents IE from caching REST requests
  Future<Request> _noCache(Request request) async {
    request = request.change(headers: <String, Object>{
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    });

    return request;
  }

  // Returns maintenance error code
  Future<Response> _doMaintenance(Response res) async {
    // Make this more sophisticated
    if (_maintenanceEnabled) {
      res.change(headers: {'Retry-After': '3600'});
      res = Response(503,
          body: await res.readAsString(),
          headers: res.headers,
          encoding: res.encoding,
          context: res.context);
    }
    return res;
  }

  /// Closes this endpoint and the REST server (service) that was opened earlier.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// Return              once the closing process is complete.
  ///                     Will be called with an error if one is raised.
  @override
  Future close(String? correlationId) async {
    if (_server != null) {
      // Eat exceptions
      try {
        await _server!.close();
        // await _app.close();

        _logger.debug(correlationId, 'Closed REST service at %s', [_uri]);
      } catch (ex) {
        _logger
            .warn(correlationId, 'Failed while closing REST service: %s', [ex]);
        rethrow;
      }

      _server = null;
      _app = null;
      _uri = null;
    }
  }

  /// Registers a registerable object for dynamic endpoint discovery.
  ///
  /// - [registration]      the IRegisterable registration to add.
  ///
  /// See [IRegisterable]
  void register(IRegisterable registration) {
    _registrations.add(registration);
  }

  /// Unregisters a registerable object, so that it is no longer used in dynamic
  /// endpoint discovery.
  ///
  /// - [registration]      the IRegisterable registration to remove.
  ///
  /// See [IRegisterable]
  void unregister(IRegisterable registration) {
    _registrations.remove(registration);
  }

  void _performRegistrations() {
    for (var registration in _registrations) {
      registration.register();
    }
  }

  String _fixRoute(String? route) {
    if (route != null && route.isNotEmpty && !route.startsWith('/')) {
      route = '/' + route;
    }
    return route ?? '';
  }

  /// Registers an action in this objects REST server (service) by the given method and route.
  ///
  /// - [method]        the HTTP method of the route.
  /// - [route]         the route to register in this object's REST server (service).
  /// - [schema]        the schema to use for parameter validation.
  /// - [action]        the action to perform at the given route.
  void registerRoute(String method, String route, Schema? schema,
      FutureOr<Response> Function(Request req) action) {
    if (_app == null) {
      throw ApplicationException('', 'NOT_OPENED', 'Can\'t add route');
    }

    method = method.toUpperCase();
    if (method == 'DEL') method = 'DELETE';

    route = _fixRoute(route);

    var actionCurl = (Request req) async {
      // Perform validation
      if (schema != null) {
        var params = <dynamic, dynamic>{};

        // query parameters
        req.url.queryParameters.forEach((key, value) {
          params.addAll({key: value});
        });

        // route parameters
        req.params.forEach((key, value) {
          params.addAll({key: value});
        });

        if (req.headers.containsKey('Content-Type')) {
          var body = await req.readAsString();
          var mapBody = body.isNotEmpty ? json.decode(body) : {};
          params.addAll({'body': mapBody});
          req = req.change(body: body);
        }

        var correlationId = getCorrelationId(req);
        var err =
            schema.validateAndReturnException(correlationId, params, false);
        if (err != null) {
          return HttpResponseSender.sendError(req, err);
        }
      }
      return await action(req);
    };
    _app!.add(method, route, actionCurl);
  }

  /// Returns correlationId from request
  /// - [req] -  http request
  /// Returns Returns correlationId from request
  String? getCorrelationId(Request req) {
    var correlationId = req.url.queryParameters['correlation_id'];
    if (correlationId == null || correlationId == '') {
      correlationId = req.headers['correlation_id'];
    }
    return correlationId;
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
      FutureOr<Response?> Function(Request req, Future Function() next)?
          authorize,
      FutureOr<Response> Function(Request req) action) {
    if (authorize != null) {
      var nextAction = action;
      action = _action(authorize, nextAction);
    }

    registerRoute(method, route, schema, action);
  }

  FutureOr<Response> Function(Request req) _action(
      Function auth, Function nextAction) {
    return (Request req) async {
      return await auth(req, () {
            return nextAction(req);
          }) ??
          Response.forbidden('');
    };
  }

  /// Registers a middleware action for the given route.
  ///
  /// - [route]         the route to register in this object's REST server (service).
  /// - [action]        the middleware action to perform at the given route.
  void registerInterceptor(String? route, Function(Request req) action) {
    route = route != null && route.startsWith('/') ? route.substring(1) : route;
    _interceptors.add((Request req) async {
      var regExp = RegExp(
        route ?? '',
        caseSensitive: true,
        multiLine: false,
      );

      var match = regExp.hasMatch(req.url.path);
      if (route != null && route != '' && !match) {
        return null;
      } else {
        return await action(req);
      }
    });
  }
}

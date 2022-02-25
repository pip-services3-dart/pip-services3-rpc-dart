import 'dart:async';
import 'dart:io';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_components/src/trace/CompositeTracer.dart';
import 'package:shelf/shelf.dart';

import '../../pip_services3_rpc.dart';
import './HttpEndpoint.dart';
import './IRegisterable.dart';
import './HttpResponseSender.dart';

/// Abstract service that receives remove calls via HTTP/REST protocol.
///
/// ### Configuration parameters ###
///
/// - [base_route]:              base route for remote URI
/// - [dependencies]:
///   - [endpoint]:              override for HTTP Endpoint dependency
///   - [controller]:            override for Controller dependency
/// - [connection](s):
///   - [discovery_key]:         (optional) a key to retrieve the connection from [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html)
///   - [protocol]:              connection protocol: http or https
///   - [host]:                  host name or IP address
///   - [port]:                  port number
///   - [uri]:                   resource URI or connection string with all parameters in it
/// - [credential] - the HTTPS credentials:
///   - [ssl_key_file]:         the SSL private key in PEM
///   - [ssl_crt_file]:         the SSL certificate in PEM
///   - [ssl_ca_file]:          the certificate authorities (root cerfiticates) in PEM
///
/// ### References ###
///
/// - [\*:logger:\*:\*:1.0]               (optional) [ILogger](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ILogger-class.html) components to pass log messages
/// - [\*:counters:\*:\*:1.0]             (optional) [ICounters](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ICounters-class.html) components to pass collected measurements
/// - [\*:discovery:\*:\*:1.0]            (optional) [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html) services to resolve connection
/// - [\*:endpoint:http:\*:1.0]          (optional) [HttpEndpoint] reference
///
/// See [RestClient]
///
/// ### Example ###
///
///     class MyRestService extends RestService {
///         IMyController _controller;
///        ...
///        MyRestService(): base() {
///           dependencyResolver.put(
///               'controller',
///               Descriptor('mygroup','controller','*','*','1.0')
///           );
///        }
///
///        void setReferences(references: IReferences) {
///           base.setReferences(references);
///           _controller = dependencyResolver.getRequired<IMyController>('controller');
///        }
///
///        void register() {
///            registerRoute('get', 'get_mydata', null, (req, res)  {
///                var correlationId = req.param('correlation_id');
///                var id = req.param('id');
///                var result = await _controller.getMyData(correlationId, id);
///                sendResult(req,  null, result);
///            });
///            ...
///        }
///     }
///
///     var service = MyRestService();
///     service.configure(ConfigParams.fromTuples([
///         'connection.protocol', 'http',
///         'connection.host', 'localhost',
///         'connection.port', 8080
///     ]));
///     service.setReferences(References.fromTuples([
///        Descriptor('mygroup','controller','default','default','1.0'), controller
///     ]));
///
///     await service.open('123');
///     print('The REST service is running on port 8080');
///

abstract class RestService
    implements
        IOpenable,
        IConfigurable,
        IReferenceable,
        IUnreferenceable,
        IRegisterable {
  static final _defaultConfig = ConfigParams.fromTuples([
    'base_route',
    null,
    'dependencies.endpoint',
    '*:endpoint:http:*:1.0',
    'dependencies.swagger',
    '*:swagger-service:*:*:1.0'
  ]);

  ConfigParams? config;
  IReferences? _references;
  bool _localEndpoint = false;
  bool _opened = false;

  /// The base route.
  String? baseRoute;

  /// The HTTP endpoint that exposes this service.
  HttpEndpoint? endpoint;

  /// The dependency resolver.
  var dependencyResolver = DependencyResolver(RestService._defaultConfig);

  /// The logger.
  var logger = CompositeLogger();

  /// The performance counters.
  var counters = CompositeCounters();

  // The tracer.
  var tracer = CompositeTracer();

  ISwaggerService? _swaggerService;
  bool swaggerEnable = false;
  String swaggerRoute = 'swagger';

  /// Configures component by passing configuration parameters.
  ///
  /// - [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    config = config.setDefaults(RestService._defaultConfig);
    this.config = config;
    dependencyResolver.configure(config);
    baseRoute = config.getAsNullableString('base_route') ?? baseRoute;
    swaggerEnable =
        config.getAsBooleanWithDefault('swagger.enable', swaggerEnable);
    swaggerRoute = config.getAsStringWithDefault('swagger.route', swaggerRoute);
  }

  /// Sets references to dependent components.
  ///
  /// - [references] 	references to locate the component dependencies.
  @override
  void setReferences(IReferences references) {
    _references = references;

    logger.setReferences(references);
    counters.setReferences(references);
    dependencyResolver.setReferences(references);

    // Get endpoint
    endpoint = dependencyResolver.getOneOptional<HttpEndpoint>('endpoint');
    // Or create a local one
    if (endpoint == null) {
      endpoint = _createEndpoint();
      _localEndpoint = true;
    } else {
      _localEndpoint = false;
    }
    // Add registration callback to the endpoint
    endpoint!.register(this);

    _swaggerService =
        dependencyResolver.getOneOptional<ISwaggerService>('swagger');
  }

  /// Unsets (clears) previously set references to dependent components.
  @override
  void unsetReferences() {
    // Remove registration callback from endpoint
    if (endpoint != null) {
      endpoint!.unregister(this);
      endpoint = null;
    }

    _swaggerService = null;
  }

  HttpEndpoint _createEndpoint() {
    var endpoint = HttpEndpoint();

    if (config != null) {
      endpoint.configure(config!);
    }

    if (_references != null) {
      endpoint.setReferences(_references!);
    }

    return endpoint;
  }

  /// Adds instrumentation to log calls and measure call time.
  /// It returns a Timing object that is used to end the time measurement.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [name]              a method name.
  /// Returns               [InstrumentTiming] object to end the time measurement.
  InstrumentTiming instrument(String? correlationId, String name) {
    logger.trace(correlationId, 'Executing %s method', [name]);
    counters.incrementOne(name + '.exec_count');

    var counterTiming = counters.beginTiming(name + '.exec_time');
    var traceTiming = tracer.beginTrace(correlationId, name, '');

    return InstrumentTiming(correlationId, name, 'exec', logger, counters,
        counterTiming, traceTiming);
  }

  /// Adds instrumentation to error handling.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [name]              a method name.
  /// - [err]               an occured error
  void instrumentError(String? correlationId, String name, err,
      [bool? reerror = false]) {
    if (err != null) {
      logger.error(correlationId, ApplicationException().wrap(err),
          'Failed to execute %s method', [name]);
      counters.incrementOne(name + '.exec_errors');
      if (reerror != null && reerror == true) {
        throw err;
      }
    }
  }

  /// Checks if the component is opened.
  ///
  /// Returns true if the component has been opened and false otherwise.
  @override
  bool isOpen() {
    return _opened;
  }

  /// Opens the component.
  ///
  /// - [correlationId] 	(optional) transaction id to trace execution through call chain.
  /// Return 			Future that receives null no errors occured.
  /// Throws error
  @override
  Future open(String? correlationId) async {
    if (_opened) {
      return null;
    }

    if (endpoint == null) {
      endpoint = _createEndpoint();
      endpoint!.register(this);
      _localEndpoint = true;
    }

    if (_localEndpoint) {
      await endpoint!.open(correlationId);
    }
    _opened = true;
    return null;
  }

  /// Closes component and frees used resources.
  ///
  /// - [correlationId] 	(optional) transaction id to trace execution through call chain.
  /// Return			        Future that receives null no errors occured.
  /// throws error
  ///
  @override
  Future close(String? correlationId) async {
    if (!_opened) {
      return null;
    }

    if (endpoint == null) {
      throw InvalidStateException(
          correlationId, 'NOendpoint', 'HTTP endpoint is missing');
    }

    if (_localEndpoint) {
      await endpoint!.close(correlationId);
    }
    _opened = false;
    return null;
  }

  /// Sends result as JSON object.
  /// That function call be called directly or passed
  /// as a parameter to business logic components.
  ///
  /// If object is not null it returns 200 status code.
  /// For null results it returns 204 status code.
  /// If error occur it sends ErrorDescription with approproate status code.
  ///
  /// - [req]       a HTTP request object.
  FutureOr<Response> sendResult(Request req, result) async {
    return await HttpResponseSender.sendResult(req, result);
  }

  /// Creates function that sends newly created object as JSON.
  /// That function call be called directly or passed
  /// as a parameter to business logic components.
  ///
  /// If object is not null it returns 201 status code.
  /// For null results it returns 204 status code.
  /// If error occur it sends ErrorDescription with approproate status code.
  ///
  /// - [req]       a HTTP request object.
  FutureOr<Response> sendCreatedResult(Request req, result) async {
    return await HttpResponseSender.sendCreatedResult(req, result);
  }

  /// Creates a function that sends deleted object as JSON.
  /// That function call be called directly or passed
  /// as a parameter to business logic components.
  ///
  /// If object is not null it returns 200 status code.
  /// For null results it returns 204 status code.
  /// If error occur it sends ErrorDescription with approproate status code.
  ///
  /// - [req]       a HTTP request object.
  /// - [result]       a result object.
  FutureOr<Response> sendDeletedResult(Request req, result) async {
    return await HttpResponseSender.sendDeletedResult(req, result);
  }

  /// Sends error serialized as ErrorDescription object
  /// and appropriate HTTP status code.
  /// If status code is not defined, it uses 500 status code.
  ///
  /// - [req]       a HTTP request object.
  /// - [res]       a HTTP response object.
  /// - [error]     an error object to be sent.
  FutureOr<Response> sendError(Request req, error) async {
    return await HttpResponseSender.sendError(req, error);
  }

  String _appendBaseRoute(String? route) {
    route ??= '/';
    if (baseRoute != null && baseRoute!.isNotEmpty) {
      var baseRoute = this.baseRoute;
      if (route.isEmpty) {
        route = '/';
      }
      if (route[0] != '/') {
        route = '/' + route;
      }
      if (baseRoute![0] != '/') {
        baseRoute = '/' + baseRoute;
      }
      route = baseRoute + route;
    }
    return route;
  }

  /// Registers a route in HTTP endpoint.
  ///
  /// - [method]        HTTP method: 'get', 'head', 'post', 'put', 'delete'
  /// - [route]         a command route. Base route will be added to this route
  /// - [schema]        a validation schema to validate received parameters.
  /// - [action]        an action function that is called when operation is invoked.
  void registerRoute(String method, String route, Schema? schema,
      FutureOr<Response> Function(Request req) action) {
    if (endpoint == null) return;
    route = _appendBaseRoute(route);
    endpoint!.registerRoute(method, route, schema, action);
  }

  /// Registers a route with authorization in HTTP endpoint.
  ///
  /// - [method]        HTTP method: 'get', 'head', 'post', 'put', 'delete'
  /// - [route]         a command route. Base route will be added to this route
  /// - [schema]        a validation schema to validate received parameters.
  /// - [authorize]     an authorization interceptor
  /// - [action]        an action function that is called when operation is invoked.
  void registerRouteWithAuth(
      String method,
      String route,
      Schema schema,
      FutureOr<Response?> Function(Request req, Future Function() next)
          authorize,
      FutureOr<Response> Function(Request req) action) {
    if (endpoint == null) return;

    route = _appendBaseRoute(route);

    endpoint!.registerRouteWithAuth(method, route, schema, authorize, action);
  }

  /// Registers a middleware for a given route in HTTP endpoint.
  ///
  /// - [route]         a command route. Base route will be added to this route
  /// - [action]        an action function that is called when middleware is invoked.
  void registerInterceptor(String route, Function(Request req) action) {
    if (endpoint == null) return;
    route = _appendBaseRoute(route);
    endpoint!.registerInterceptor(route, action);
  }

  /// Registers all service routes in HTTP endpoint.
  ///
  /// This method is called by the service and must be overriden
  /// in child classes.
  @override
  void register();

  void registerOpenApiSpecFromFile(String path) async {
    var file = File(path);
    var content = file.readAsStringSync();
    registerOpenApiSpec_(content);
  }

  void registerOpenApiSpec_(String content) {
    if (!swaggerEnable) return;

    registerRoute('get', swaggerRoute, null, (Request req) async {
      return Response(200, body: content, headers: {
        'Content-Length': content.length.toString(),
        'Content-Type': 'application/x-yaml'
      });
    });

    if (_swaggerService != null) {
      _swaggerService?.registerOpenApiSpec(baseRoute, swaggerRoute);
    }
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
}

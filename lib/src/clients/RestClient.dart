import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';
import '../connect/HttpConnectionResolver.dart';

/// Abstract client that calls remove endpoints using HTTP/REST protocol.
///
/// ### Configuration parameters ###
///
/// - [base_route]:              base route for remote URI
/// - [connection](s):
///   - [discovery_key]:         (optional) a key to retrieve the connection from [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]]
///   - [protocol]:              connection protocol: http or https
///   - [host]:                  host name or IP address
///   - [port]:                  port number
///   - [uri]:                   resource URI or connection string with all parameters in it
/// - [options]:
///   - [retries]:               number of retries (default: 3)
///   - [connecttimeout]:       connection timeout in milliseconds (default: 10 sec)
///   - [timeout]:               invocation timeout in milliseconds (default: 10 sec)
///
/// ### References ###
///
/// - \*:logger:\*:\*:1.0         (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/log.ilogger.html ILogger]] components to pass log messages
/// - \*:counters:\*:\*:1.0         (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/count.icounters.html ICounters]] components to pass collected measurements
/// - \*:discovery:\*:\*:1.0        (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]] services to resolve connection
///
/// See [[RestService]]
/// See [[CommandableHttpService]]
///
/// ### Example ###
///
///     class MyRestClient extends RestClient implements IMyClient {
///        ...
///
///         getData(String correlationId, String id,
///            callback: (err: any, result: MyData) => void): void {
///
///            var timing = instrument(correlationId, 'myclient.get_data');
///            this.call('get', '/get_data' correlationId, { id: id }, null, (err, result) => {
///                timing.endTiming();
///                callback(err, result);
///            });
///        }
///        ...
///     }
///
///     var client = MyRestClient();
///     client.configure(ConfigParams.fromTuples([
///         'connection.protocol', 'http',
///         'connection.host', 'localhost',
///         'connection.port', 8080
///     ]));
///
///     client.getData('123', '1', (err, result) => {
///       ...
///     });

abstract class RestClient implements IOpenable, IConfigurable, IReferenceable {
  static final _defaultConfig = ConfigParams.fromTuples([
    'connection.protocol',
    'http',
    'connection.host',
    '0.0.0.0',
    'connection.port',
    3000,
    'options.request_max_size',
    1024 * 1024,
    'options.connecttimeout',
    10000,
    'options.timeout',
    10000,
    'options.retries',
    3,
    'options.debug',
    true
  ]);

  /// The HTTP client.
  http.Client client;

  /// The connection resolver.
  var connectionResolver = HttpConnectionResolver();

  /// The logger.
  var logger = CompositeLogger();

  /// The performance counters.
  var counters = CompositeCounters();

  /// The configuration options.
  var options = ConfigParams();

  /// The base route.
  String baseRoute;

  /// The number of retries.
  int retries = 1;

  /// The default headers to be added to every request.
  var headers = <String, String>{};

  /// The connection timeout in milliseconds.
  int connectTimeout = 10000;

  /// The invocation timeout in milliseconds.
  int timeout = 10000;

  /// The remote service uri which is calculated on open.
  String uri;

  /// Configures component by passing configuration parameters.
  ///
  /// - [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    config = config.setDefaults(RestClient._defaultConfig);
    connectionResolver.configure(config);
    options = options.override(config.getSection('options'));

    retries = config.getAsIntegerWithDefault('options.retries', retries);
    connectTimeout = config.getAsIntegerWithDefault(
        'options.connecttimeout', connectTimeout);
    timeout = config.getAsIntegerWithDefault('options.timeout', timeout);

    baseRoute = config.getAsStringWithDefault('base_route', baseRoute);
  }

  /// Sets references to dependent components.
  ///
  /// - [references] 	references to locate the component dependencies.
  @override
  void setReferences(IReferences references) {
    logger.setReferences(references);
    counters.setReferences(references);
    connectionResolver.setReferences(references);
  }

  /// Adds instrumentation to log calls and measure call time.
  /// It returns a Timing object that is used to end the time measurement.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [name]              a method name.
  /// Returns Timing object to end the time measurement.
  Timing instrument(String correlationId, String name) {
    logger.trace(correlationId, 'Calling %s method', [name]);
    counters.incrementOne(name + '.call_count');
    return counters.beginTiming(name + '.call_time');
  }

  /// Adds instrumentation to error handling.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [name]              a method name.
  /// - [err]               an occured error
  /// - [result]            (optional) an execution result
  void instrumentError(String correlationId, String name, err,
      [bool reerror = false]) {
    if (err != null) {
      logger.error(correlationId, err, 'Failed to call %s method', [name]);
      counters.incrementOne(name + '.call_errors');
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
    return client != null;
  }

  /// Opens the component.
  ///
  /// - [correlationId] 	(optional) transaction id to trace execution through call chain.
  /// Return 			Future that receives null no errors occured.
  /// Throws error
  @override
  Future open(String correlationId) async {
    if (isOpen()) {
      return null;
    }

    var connection = await connectionResolver.resolve(correlationId);

    try {
      uri = connection.getUri();
      client = http.Client();
      // this.client = restify.createJsonClient({
      //     url: this.uri,
      //     connectTimeout: this.connectTimeout,
      //     requestTimeout: this.timeout,
      //     headers: this.headers,
      //     retry: {
      //         minTimeout: this.timeout,
      //         maxTimeout: Infinity,
      //         retries: this.retries
      //     },
      //     version: '*'
      // });

    } catch (err) {
      client = null;
      throw ConnectionException(correlationId, 'CANNOT_CONNECT',
              'Connection to REST service failed')
          .wrap(err)
          .withDetails('url', uri);
    }
  }

  /// Closes component and frees used resources.
  ///
  /// - correlationId 	(optional) transaction id to trace execution through call chain.
  /// Return			Future that receives null no errors occured.
  /// Throws error
  @override
  Future close(String correlationId) async {
    if (client != null) {
      // Eat exceptions
      try {
        logger.debug(correlationId, 'Closed REST service at %s', [uri]);
      } catch (ex) {
        logger.warn(correlationId, 'Failed while closing REST service: %s', ex);
      }

      client = null;
      uri = null;
    }
  }

  /// Adds a correlation id (correlation_id) to invocation parameter map.
  ///
  /// - [params]            invocation parameters.
  /// - [correlationId]     (optional) a correlation id to be added.
  /// Returns invocation parameters with added correlation id.

  Map<String, String> addCorrelationId(
      Map<String, String> params, String correlationId) {
    // Automatically generate short ids for now
    if (correlationId == null) {
      return params;
    }

    params = params ?? {};
    params['correlation_id'] = correlationId;
    return params;
  }

  /// Adds filter parameters (with the same name as they defined)
  /// to invocation parameter map.
  ///
  /// - [params]        invocation parameters.
  /// - [filter]        (optional) filter parameters
  /// Returns invocation parameters with added filter parameters.
  Map<String, String> addFilterParams(
      Map<String, String> params, FilterParams filter) {
    params = params ?? {};

    if (filter != null) {
      for (var prop in filter.values) {
        //if (filter.hasOwnProperty(prop))
        params[prop] = filter[prop];
      }
    }

    return params;
  }

  /// Adds paging parameters (skip, take, total) to invocation parameter map.
  ///
  /// - [params]        invocation parameters.
  /// - [paging]        (optional) paging parameters
  /// Returns invocation parameters with added paging parameters.
  Map<String, String> addPagingParams(
      Map<String, String> params, PagingParams paging) {
    params = params ?? {};

    if (paging != null) {
      if (paging.total) {
        params['total'] = paging.total.toString();
      }
      if (paging.skip > 0) {
        params['skip'] = paging.skip.toString();
      }
      if (paging.take > 0) {
        params['take'] = paging.take.toString();
      }
    }

    return params;
  }

  String createRequestRoute(String route) {
    var builder = '';

    if (baseRoute != null && baseRoute.isNotEmpty) {
      if (baseRoute[0] != '/') {
        builder += '/';
      }
      builder += baseRoute;
    }

    if (route[0] != '/') {
      builder += '/';
    }
    builder += route;

    return builder;
  }

  /// Calls a remote method via HTTP/REST protocol.
  ///
  /// - [method]            HTTP method: 'get', 'head', 'post', 'put', 'delete'
  /// - [route]             a command route. Base route will be added to this route
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [params]            (optional) query parameters.
  /// - [data]              (optional) body object.
  /// Returns          Future that receives result object
  /// Throw error.

  Future call(String method, String route, String correlationId, Map params,
      [data]) async {
    method = method.toLowerCase();

    // if (data != null && data is Function) {
    //     callback = data;
    //     data = {};
    // }

    route = createRequestRoute(route);
    params = addCorrelationId(params, correlationId);
    if (params.isNotEmpty) {
      //   route += '?' + querystring.stringify(params);
      var uri = Uri(queryParameters: params);
      route += uri.toString();
    }

    http.Response response;

    var retriesCount = retries;

    for (; retries > 0;) {
      try {
        if (method == 'get') {
          response = await client.get(route, headers: headers); 
        } else if (method == 'head') {
          response = await client.head(route, headers: headers); 
        } else if (method == 'post') {
          response =
              await client.post(route, headers: headers, body: data); 
        } else if (method == 'put') {
          response =
              await client.put(route, headers: headers, body: data); 
        } else if (method == 'delete') {
          response = await client.delete(route, headers: headers); 
        } else {
          var error = UnknownException(correlationId, 'UNSUPPORTED_METHOD',
                  'Method is not supported by REST client')
              .withDetails('verb', method);
          throw error;
        }
      } catch (ex) {
        retriesCount--;
        if (retriesCount == 0) {
          rethrow;
        } else {
          logger.trace(
              correlationId, "Connection failed to uri '${uri}'. Retrying...");
        }
      }
    }

    if (response.statusCode == 204) {
      return null;
    }

     if (response == null)
            {
                throw ApplicationExceptionFactory.create(ErrorDescriptionFactory.create(
                     UnknownException(correlationId, 'Unable to get a result from uri ${uri} with method ${method}')));
            }

   return response;
  }
}

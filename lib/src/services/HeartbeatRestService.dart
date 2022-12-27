import 'dart:async';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:shelf/shelf.dart';
import './RestService.dart';

/// Service returns heartbeat via HTTP/REST protocol.
///
/// The service responds on /heartbeat route (can be changed)
/// with a string with the current time in UTC.
///
/// This service route can be used to health checks by loadbalancers and
/// container orchestrators.
///
/// ### Configuration parameters ###
///
/// - [base_route]:              base route for remote URI (default: '')
/// - [route]:                   route to heartbeat operation (default: 'heartbeat')
/// - [dependencies]:
///   - [endpoint]:              override for HTTP Endpoint dependency
/// - [connection(s)]:
///   - [discovery_key]:         (optional) a key to retrieve the connection from [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html)
///   - [protocol]:              connection protocol: http or https
///   - [host]:                  host name or IP address
///   - [port]:                  port number
///   - [uri]:                   resource URI or connection string with all parameters in it
///
/// ### References ###
///
/// - [\*:logger:\*:\*:1.0]               (optional) [ILogger](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ILogger-class.html) components to pass log messages
/// - [\*:counters:\*:\*:1.0]             (optional) [ICounters](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ICounters-class.html) components to pass collected measurements
/// - [\*:discovery:\*:\*:1.0]            (optional) [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html) services to resolve connection
/// - [\*:endpoint:http:\*:1.0]           (optional) [HttpEndpoint] reference
///
/// See [RestService]
/// See [RestClient]
///
/// ### Example ###
///
///     var service = new HeartbeatService();
///     service.configure(ConfigParams.fromTuples(
///         'route', 'ping',
///         'connection.protocol', 'http',
///         'connection.host', 'localhost',
///         'connection.port', 8080
///     ));
///
///     service.open('123', (err) => {
///        console.log('The Heartbeat service is accessible at http://+:8080/ping');
///     });

class HeartbeatRestService extends RestService {
  var _route = 'heartbeat';

  /// Creates a new instance of this service.
  HeartbeatRestService() : super();

  /// Configures component by passing configuration parameters.
  ///
  /// - [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    super.configure(config);

    _route = config.getAsStringWithDefault('route', _route);
  }

  /// Registers all service routes in HTTP endpoint.
  @override
  void register() {
    registerRoute('get', _route, null, (Request req) async {
      return await _heartbeat(req);
    });
  }

  /// Handles heartbeat requests
  ///
  /// - [req]   an HTTP RequestContext
  /// - [res]   an HTTP ResponseContext
  FutureOr<Response> _heartbeat(Request req) async {
    return await sendResult(req, DateTime.now().toUtc().toIso8601String());
  }
}

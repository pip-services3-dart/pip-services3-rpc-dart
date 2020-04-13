
import 'package:angel_framework/angel_framework.dart' as angel;
import  'package:pip_services3_commons/pip_services3_commons.dart';
import  './RestService.dart';

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
/// - base_route:              base route for remote URI (default: '')
/// - route:                   route to heartbeat operation (default: 'heartbeat')
/// - dependencies:
///   - endpoint:              override for HTTP Endpoint dependency
/// - connection(s):           
///   - discovery_key:         (optional) a key to retrieve the connection from [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]]
///   - protocol:              connection protocol: http or https
///   - host:                  host name or IP address
///   - port:                  port number
///   - uri:                   resource URI or connection string with all parameters in it
/// 
/// ### References ###
/// 
/// - [\*:logger:\*:\*:1.0]               (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/log.ilogger.html ILogger]] components to pass log messages
/// - [\*:counters:\*:\*:1.0]             (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/count.icounters.html ICounters]] components to pass collected measurements
/// - [\*:discovery:\*:\*:1.0]            (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]] services to resolve connection
/// - [\*:endpoint:http:\*:1.0]          (optional) [[HttpEndpoint]] reference
/// 
/// See [[RestService]]
/// See [[RestClient]]
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
     
    HeartbeatRestService(): super(); 

    
    /// Configures component by passing configuration parameters.
    /// 
    /// - config    configuration parameters to be set.
    @override 
    void configure(ConfigParams config) {
        super.configure(config);

        _route = config.getAsStringWithDefault('route', _route);
    }

    
    /// Registers all service routes in HTTP endpoint.
     
    @override
  void register() {
        registerRoute('get', _route, null, (angel.RequestContext req, angel.ResponseContext res)  { _heartbeat(req, res); });
    }

    
    /// Handles heartbeat requests
    /// 
    /// - req   an HTTP request
    /// - res   an HTTP response
     
    void _heartbeat(angel.RequestContext req, angel.ResponseContext res) {
        sendResult(req, res, null, DateTime.now().toIso8601String());
    }
}
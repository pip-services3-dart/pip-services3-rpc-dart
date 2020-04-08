// /** @module services */
// import { RestService } from './RestService';
// import { ConfigParams } from 'pip-services3-commons-node';

// /**
//  * Service returns heartbeat via HTTP/REST protocol.
//  * 
//  * The service responds on /heartbeat route (can be changed)
//  * with a string with the current time in UTC.
//  * 
//  * This service route can be used to health checks by loadbalancers and 
//  * container orchestrators.
//  * 
//  * ### Configuration parameters ###
//  * 
//  * - base_route:              base route for remote URI (default: "")
//  * - route:                   route to heartbeat operation (default: "heartbeat")
//  * - dependencies:
//  *   - endpoint:              override for HTTP Endpoint dependency
//  * - connection(s):           
//  *   - discovery_key:         (optional) a key to retrieve the connection from [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]]
//  *   - protocol:              connection protocol: http or https
//  *   - host:                  host name or IP address
//  *   - port:                  port number
//  *   - uri:                   resource URI or connection string with all parameters in it
//  * 
//  * ### References ###
//  * 
//  * - <code>\*:logger:\*:\*:1.0</code>               (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/log.ilogger.html ILogger]] components to pass log messages
//  * - <code>\*:counters:\*:\*:1.0</code>             (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/count.icounters.html ICounters]] components to pass collected measurements
//  * - <code>\*:discovery:\*:\*:1.0</code>            (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]] services to resolve connection
//  * - <code>\*:endpoint:http:\*:1.0</code>          (optional) [[HttpEndpoint]] reference
//  * 
//  * @see [[RestService]]
//  * @see [[RestClient]]
//  * 
//  * ### Example ###
//  * 
//  *     let service = new HeartbeatService();
//  *     service.configure(ConfigParams.fromTuples(
//  *         "route", "ping",
//  *         "connection.protocol", "http",
//  *         "connection.host", "localhost",
//  *         "connection.port", 8080
//  *     ));
//  * 
//  *     service.open("123", (err) => {
//  *        console.log("The Heartbeat service is accessible at http://+:8080/ping");
//  *     });
//  */
// export class HeartbeatRestService extends RestService {
//     private _route: string = "heartbeat";

//     /**
//      * Creates a new instance of this service.
//      */
//     public constructor() {
//         super();
//     }

//     /**
//      * Configures component by passing configuration parameters.
//      * 
//      * @param config    configuration parameters to be set.
//      */
//     public configure(config: ConfigParams): void {
//         super.configure(config);

//         this._route = config.getAsStringWithDefault("route", this._route);
//     }

//     /**
//      * Registers all service routes in HTTP endpoint.
//      */
//     public register(): void {
//         this.registerRoute("get", this._route, null, (req, res) => { this.heartbeat(req, res); });
//     }

//     /**
//      * Handles heartbeat requests
//      * 
//      * @param req   an HTTP request
//      * @param res   an HTTP response
//      */
//     private heartbeat(req, res): void {
//         this.sendResult(req, res)(null, new Date());
//     }
// }
// /** @module build */
// import { Factory } from 'pip-services3-components-node';
// import { Descriptor } from 'pip-services3-commons-node';

// import { HttpEndpoint } from '../services/HttpEndpoint';
// import { HeartbeatRestService } from '../services/HeartbeatRestService';
// import { StatusRestService } from '../services/StatusRestService';

// /**
//  * Creates RPC components by their descriptors.
//  * 
//  * @see [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/classes/build.factory.html Factory]]
//  * @see [[HttpEndpoint]]
//  * @see [[HeartbeatRestService]]
//  * @see [[StatusRestService]] 
//  */
// export class DefaultRpcFactory extends Factory {
// 	public static readonly Descriptor: Descriptor = new Descriptor("pip-services", "factory", "rpc", "default", "1.0");
//     public static readonly HttpEndpointDescriptor: Descriptor = new Descriptor("pip-services", "endpoint", "http", "*", "1.0");
//     public static readonly StatusServiceDescriptor = new Descriptor("pip-services", "status-service", "http", "*", "1.0");
//     public static readonly HeartbeatServiceDescriptor = new Descriptor("pip-services", "heartbeat-service", "http", "*", "1.0");

//     /**
// 	 * Create a new instance of the factory.
// 	 */
//     public constructor() {
//         super();
//         this.registerAsType(DefaultRpcFactory.HttpEndpointDescriptor, HttpEndpoint);
//         this.registerAsType(DefaultRpcFactory.HeartbeatServiceDescriptor, HeartbeatRestService);
//         this.registerAsType(DefaultRpcFactory.StatusServiceDescriptor, StatusRestService);
//     }
// }

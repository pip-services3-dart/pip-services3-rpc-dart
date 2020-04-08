// /** @module clients */
// import { IOpenable } from 'pip-services3-commons-node';
// import { IConfigurable } from 'pip-services3-commons-node';
// import { IReferenceable } from 'pip-services3-commons-node';
// import { IReferences } from 'pip-services3-commons-node';
// import { DependencyResolver } from 'pip-services3-commons-node';
// import { CompositeLogger } from 'pip-services3-components-node';
// import { CompositeCounters } from 'pip-services3-components-node';
// import { ConfigParams } from 'pip-services3-commons-node';
// import { Timing } from 'pip-services3-components-node';
// import { ConnectionException } from 'pip-services3-commons-node';

// /**
//  * Abstract client that calls controller directly in the same memory space.
//  * 
//  * It is used when multiple microservices are deployed in a single container (monolyth)
//  * and communication between them can be done by direct calls rather then through 
//  * the network.
//  * 
//  * ### Configuration parameters ###
//  * 
//  * - dependencies:
//  *   - controller:            override controller descriptor
//  * 
//  * ### References ###
//  * 
//  * - <code>\*:logger:\*:\*:1.0</code>         (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/log.ilogger.html ILogger]] components to pass log messages
//  * - <code>\*:counters:\*:\*:1.0</code>       (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/count.icounters.html ICounters]] components to pass collected measurements
//  * - <code>\*:controller:\*:\*:1.0</code>     controller to call business methods
//  * 
//  * ### Example ###
//  * 
//  *     class MyDirectClient extends DirectClient<IMyController> implements IMyClient {
//  * 
//  *         public constructor() {
//  *           super();
//  *           this._dependencyResolver.put('controller', new Descriptor(
//  *               "mygroup", "controller", "*", "*", "*"));
//  *         }
//  *         ...
//  * 
//  *         public getData(correlationId: string, id: string, 
//  *           callback: (err: any, result: MyData) => void): void {
//  *        
//  *           let timing = this.instrument(correlationId, 'myclient.get_data');
//  *           this._controller.getData(correlationId, id, (err, result) => {
//  *              timing.endTiming();
//  *              this.instrumentError(correlationId, 'myclient.get_data', err, result, callback);
//  *           });        
//  *         }
//  *         ...
//  *     }
//  * 
//  *     let client = new MyDirectClient();
//  *     client.setReferences(References.fromTuples(
//  *         new Descriptor("mygroup","controller","default","default","1.0"), controller
//  *     ));
//  * 
//  *     client.getData("123", "1", (err, result) => {
//  *       ...
//  *     });
//  */
// export abstract class DirectClient<T> implements IConfigurable, IReferenceable, IOpenable {
//     /** 
//      * The controller reference.
//      */
//     protected _controller: T;
//     /** 
//      * The open flag.
//      */
//     protected _opened: boolean = true;
//     /** 
//      * The logger.
//      */
//     protected _logger: CompositeLogger = new CompositeLogger();
//     /** 
//      * The performance counters
//      */
//     protected _counters: CompositeCounters = new CompositeCounters();
//     /** 
//      * The dependency resolver to get controller reference.
//      */
//     protected _dependencyResolver: DependencyResolver = new DependencyResolver();
            
//     /**
//      * Creates a new instance of the client.
//      */
//     public constructor() {
//         this._dependencyResolver.put('controller', 'none');
//     }

//     /**
//      * Configures component by passing configuration parameters.
//      * 
//      * @param config    configuration parameters to be set.
//      */
//     public configure(config: ConfigParams): void {
//         this._dependencyResolver.configure(config);
//     }

//     /**
// 	 * Sets references to dependent components.
// 	 * 
// 	 * @param references 	references to locate the component dependencies. 
//      */
// 	public setReferences(references: IReferences): void {
// 		this._logger.setReferences(references);
// 		this._counters.setReferences(references);
//         this._dependencyResolver.setReferences(references);
//         this._controller = this._dependencyResolver.getOneRequired<T>('controller');
// 	}
        
//     /**
//      * Adds instrumentation to log calls and measure call time.
//      * It returns a Timing object that is used to end the time measurement.
//      * 
//      * @param correlationId     (optional) transaction id to trace execution through call chain.
//      * @param name              a method name.
//      * @returns Timing object to end the time measurement.
//      */
// 	protected instrument(correlationId: string, name: string): Timing {
//         this._logger.trace(correlationId, "Calling %s method", name);
//         this._counters.incrementOne(name + '.call_count');
// 		return this._counters.beginTiming(name + ".call_time");
// 	}

//     /**
//      * Adds instrumentation to error handling.
//      * 
//      * @param correlationId     (optional) transaction id to trace execution through call chain.
//      * @param name              a method name.
//      * @param err               an occured error
//      * @param result            (optional) an execution result
//      * @param callback          (optional) an execution callback
//      */
//     protected instrumentError(correlationId: string, name: string, err: any,
//         result: any = null, callback: (err: any, result: any) => void = null): void {
//         if (err != null) {
//             this._logger.error(correlationId, err, "Failed to call %s method", name);
//             this._counters.incrementOne(name + '.call_errors');    
//         }

//         if (callback) callback(err, result);
//     }

//     /**
// 	 * Checks if the component is opened.
// 	 * 
// 	 * @returns true if the component has been opened and false otherwise.
//      */
// 	public isOpen(): boolean {
//         return this._opened;
//     }
    
//     /**
// 	 * Opens the component.
// 	 * 
// 	 * @param correlationId 	(optional) transaction id to trace execution through call chain.
//      * @param callback 			callback function that receives error or null no errors occured.
//      */
// 	public open(correlationId: string, callback?: (err: any) => void): void {
//         if (this._opened) {
//             callback(null);
//             return;
//         }
    	
//         if (this._controller == null) {
//             let err = new ConnectionException(correlationId, 'NO_CONTROLLER', 'Controller reference is missing');
//             if (callback) {
//                 callback(err);
//                 return;
//             } else {
//                 throw err;
//             }
//         } 

//         this._opened = true;

//         this._logger.info(correlationId, "Opened direct client");
//         callback(null);
//     }

//     /**
// 	 * Closes component and frees used resources.
// 	 * 
// 	 * @param correlationId 	(optional) transaction id to trace execution through call chain.
//      * @param callback 			callback function that receives error or null no errors occured.
//      */
//     public close(correlationId: string, callback?: (err: any) => void): void {
//         if (this._opened)
//             this._logger.info(correlationId, "Closed direct client");

//         this._opened = false;

//         callback(null);
//     }

// }
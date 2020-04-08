// /** @module services */
// /** @hidden */
// const _ = require('lodash');
// const fs = require('fs');

// import { IOpenable } from 'pip-services3-commons-node';
// import { IConfigurable } from 'pip-services3-commons-node';
// import { IReferenceable } from 'pip-services3-commons-node';
// import { IReferences } from 'pip-services3-commons-node';
// import { ConfigParams } from 'pip-services3-commons-node';
// import { CompositeLogger } from 'pip-services3-components-node';
// import { CompositeCounters } from 'pip-services3-components-node';
// import { ConnectionException } from 'pip-services3-commons-node';
// import { Schema } from 'pip-services3-commons-node';

// import { HttpResponseSender } from './HttpResponseSender';
// import { HttpConnectionResolver } from '../connect/HttpConnectionResolver';
// import { IRegisterable } from './IRegisterable';

// /**
//  * Used for creating HTTP endpoints. An endpoint is a URL, at which a given service can be accessed by a client. 
//  * 
//  * ### Configuration parameters ###
//  * 
//  * Parameters to pass to the [[configure]] method for component configuration:
//  * 
//  * - connection(s) - the connection resolver's connections:
//  *     - "connection.discovery_key" - the key to use for connection resolving in a discovery service;
//  *     - "connection.protocol" - the connection's protocol;
//  *     - "connection.host" - the target host;
//  *     - "connection.port" - the target port;
//  *     - "connection.uri" - the target URI.
//  * - credential - the HTTPS credentials:
//  *     - "credential.ssl_key_file" - the SSL private key in PEM
//  *     - "credential.ssl_crt_file" - the SSL certificate in PEM
//  *     - "credential.ssl_ca_file" - the certificate authorities (root cerfiticates) in PEM
//  * 
//  * ### References ###
//  * 
//  * A logger, counters, and a connection resolver can be referenced by passing the 
//  * following references to the object's [[setReferences]] method:
//  * 
//  * - logger: <code>"\*:logger:\*:\*:1.0"</code>;
//  * - counters: <code>"\*:counters:\*:\*:1.0"</code>;
//  * - discovery: <code>"\*:discovery:\*:\*:1.0"</code> (for the connection resolver).
//  * 
//  * ### Examples ###
//  * 
//  *     public MyMethod(_config: ConfigParams, _references: IReferences) {
//  *         let endpoint = new HttpEndpoint();
//  *         if (this._config)
//  *             endpoint.configure(this._config);
//  *         if (this._references)
//  *             endpoint.setReferences(this._references);
//  *         ...
//  * 
//  *         this._endpoint.open(correlationId, (err) => {
//  *                 this._opened = err == null;
//  *                 callback(err);
//  *             });
//  *         ...
//  *     }
//  */
// export class HttpEndpoint implements IOpenable, IConfigurable, IReferenceable {

//     private static readonly _defaultConfig: ConfigParams = ConfigParams.fromTuples(
//         "connection.protocol", "http",
//         "connection.host", "0.0.0.0",
//         "connection.port", 3000,

//         "credential.ssl_key_file", null,
//         "credential.ssl_crt_file", null,
//         "credential.ssl_ca_file", null,

//         "options.maintenance_enabled", false,
//         "options.request_max_size", 1024*1024,
//         "options.file_max_size", 200*1024*1024,
//         "options.connect_timeout", 60000,
//         "options.debug", true
//     );

// 	private _server: any;
// 	private _connectionResolver: HttpConnectionResolver = new HttpConnectionResolver();
// 	private _logger: CompositeLogger = new CompositeLogger();
// 	private _counters: CompositeCounters = new CompositeCounters();
//     private _maintenanceEnabled: boolean = false;
//     private _fileMaxSize: number = 200 * 1024 * 1024;
//     private _protocolUpgradeEnabled: boolean = false;
//     private _uri: string;
//     private _registrations: IRegisterable[] = [];
    
//     /**
//      * Configures this HttpEndpoint using the given configuration parameters.
//      * 
//      * __Configuration parameters:__
//      * - __connection(s)__ - the connection resolver's connections;
//      *     - "connection.discovery_key" - the key to use for connection resolving in a discovery service;
//      *     - "connection.protocol" - the connection's protocol;
//      *     - "connection.host" - the target host;
//      *     - "connection.port" - the target port;
//      *     - "connection.uri" - the target URI.
//      *     - "credential.ssl_key_file" - SSL private key in PEM
//      *     - "credential.ssl_crt_file" - SSL certificate in PEM
//      *     - "credential.ssl_ca_file" - Certificate authority (root certificate) in PEM
//      * 
//      * @param config    configuration parameters, containing a "connection(s)" section.
//      * 
//      * @see [[https://rawgit.com/pip-services-node/pip-services3-commons-node/master/doc/api/classes/config.configparams.html ConfigParams]] (in the PipServices "Commons" package)
//      */
// 	public configure(config: ConfigParams): void {
// 		config = config.setDefaults(HttpEndpoint._defaultConfig);
// 		this._connectionResolver.configure(config);

//         this._maintenanceEnabled = config.getAsBooleanWithDefault('options.maintenance_enabled', this._maintenanceEnabled);
//         this._fileMaxSize = config.getAsLongWithDefault('options.file_max_size', this._fileMaxSize);
//         this._protocolUpgradeEnabled = config.getAsBooleanWithDefault('options.protocol_upgrade_enabled', this._protocolUpgradeEnabled);
//     }
        
//     /**
//      * Sets references to this endpoint's logger, counters, and connection resolver.
//      * 
//      * __References:__
//      * - logger: <code>"\*:logger:\*:\*:1.0"</code>
//      * - counters: <code>"\*:counters:\*:\*:1.0"</code>
//      * - discovery: <code>"\*:discovery:\*:\*:1.0"</code> (for the connection resolver)
//      * 
//      * @param references    an IReferences object, containing references to a logger, counters, 
//      *                      and a connection resolver.
//      * 
//      * @see [[https://rawgit.com/pip-services-node/pip-services3-commons-node/master/doc/api/interfaces/refer.ireferences.html IReferences]] (in the PipServices "Commons" package)
//      */
// 	public setReferences(references: IReferences): void {
// 		this._logger.setReferences(references);
// 		this._counters.setReferences(references);
// 		this._connectionResolver.setReferences(references);
// 	}

//     /**
//      * @returns whether or not this endpoint is open with an actively listening REST server.
//      */
// 	public isOpen(): boolean {
// 		return this._server != null;
// 	}
    
//     //TODO: check for correct understanding.
//     /**
//      * Opens a connection using the parameters resolved by the referenced connection
//      * resolver and creates a REST server (service) using the set options and parameters.
//      * 
//      * @param correlationId     (optional) transaction id to trace execution through call chain.
//      * @param callback          (optional) the function to call once the opening process is complete.
//      *                          Will be called with an error if one is raised.
//      */
// 	public open(correlationId: string, callback?: (err: any) => void): void {
//     	if (this.isOpen()) {
//             callback(null);
//             return;
//         }
    	
// 		this._connectionResolver.resolve(correlationId, (err, connection, credential) => {
//             if (err != null) {
//                 callback(err);
//                 return;
//             }

//             this._uri = connection.getUri();

//             try {
//                 let options: any = {};

//                 if (connection.getProtocol('http') == 'https') {
//                     let sslKeyFile = credential.getAsNullableString('ssl_key_file');
//                     let privateKey = fs.readFileSync(sslKeyFile).toString();
        
//                     let sslCrtFile = credential.getAsNullableString('ssl_crt_file');
//                     let certificate = fs.readFileSync(sslCrtFile).toString();
        
//                     let ca = [];
//                     let sslCaFile = credential.getAsNullableString('ssl_ca_file');
//                     if (sslCaFile != null) {
//                         let caText = fs.readFileSync(sslCaFile).toString();
//                         while (caText != null && caText.trim().length > 0) {
//                             let crtIndex = caText.lastIndexOf('-----BEGIN CERTIFICATE-----');
//                             if (crtIndex > -1) {
//                                 ca.push(caText.substring(crtIndex));
//                                 caText = caText.substring(0, crtIndex);
//                             }
//                         }
//                     }
        
//                     options.key = privateKey;
//                     options.certificate = certificate;
//                     //options.ca = ca;
//                 }
//                 options.handleUpgrades = this._protocolUpgradeEnabled;
                         
//                 // Create instance of restify application   
//                 let restify = require('restify'); 
//                 this._server = restify.createServer(options);
                
//                 // Configure restify application
//                 this._server.use(restify.plugins.acceptParser(this._server.acceptable));
//                 //this._server.use(restify.authorizationParser());
//                 //this._server.use(restify.CORS());
//                 this._server.use(restify.plugins.dateParser());
//                 this._server.use(restify.plugins.queryParser());
//                 this._server.use(restify.plugins.jsonp());
//                 this._server.use(restify.plugins.gzipResponse());
//                 this._server.use(restify.plugins.jsonBodyParser());
//                 // this._server.use(restify.plugins.bodyParser({ 
//                 //     maxFileSize: this._fileMaxSize
//                 // }));
//                 this._server.use(restify.plugins.conditionalRequest());
//                 //this._server.use(restify.plugins.requestExpiry());
//                 //if (options.get("throttle") != null)
//                 //     this._server.use(restify.plugins.throttle(options.get("throttle")));
                
//                 // Configure CORS requests
//                 let corsMiddleware = require('restify-cors-middleware');
//                 let cors = corsMiddleware({
//                     preflightMaxAge: 5, //Optional
//                     origins: ['*'],
//                     allowHeaders: ['Authenticate', 'x-session-id'],
//                     exposeHeaders: ['Authenticate', 'x-session-id']
//                   });
//                 this._server.pre(cors.preflight);
//                 this._server.use(cors.actual);

//                 this._server.use((req, res, next) => { this.addCompatibility(req, res, next); });
//                 this._server.use((req, res, next) => { this.noCache(req, res, next); });
//                 this._server.use((req, res, next) => { this.doMaintenance(req, res, next); });
        
//                 this.performRegistrations();

//                 this._server.listen(
//                     connection.getPort(), 
//                     connection.getHost(),
//                     (err) => {
//                         if (err == null) {
//                             // Register the service URI
//                             this._connectionResolver.register(correlationId, (err) => {
//                                 this._logger.debug(correlationId, "Opened REST service at %s", this._uri);
                                
//                                 if (callback) callback(err);
//                             });
//                         } else {
//                             // Todo: Hack!!!
//                             console.error(err);

//                             err = new ConnectionException(correlationId, "CANNOT_CONNECT", "Opening REST service failed")
//                                 .wrap(err).withDetails("url", this._uri);

//                             if (callback) callback(err);
//                         }
//                     }
//                 );
//             } catch (ex) {
//                 this._server = null;
//                 let err = new ConnectionException(correlationId, "CANNOT_CONNECT", "Opening REST service failed")
//                     .wrap(ex).withDetails("url", this._uri);
//                 if (callback) callback(err);
//             }
//         });
		
//     }

//     private addCompatibility(req: any, res: any, next: () => void): void {
//         req.param = (name) => {
//             if (req.query) {
//                 let param = req.query[name];
//                 if (param) return param;
//             }
//             if (req.body) {
//                 let param = req.body[name];
//                 if (param) return param;
//             }
//             if (req.params) {
//                 let param = req.params[name];
//                 if (param) return param;
//             }
//             return null;
//         }

//         req.route.params = req.params;

//         next();
//     }

//     // Prevents IE from caching REST requests
//     private noCache(req: any, res: any, next: () => void): void {
//         res.header('Cache-Control', 'no-cache, no-store, must-revalidate');
//         res.header('Pragma', 'no-cache');
//         res.header('Expires', 0);
//         next();
//     }

//     // Returns maintenance error code
//     private doMaintenance(req: any, res: any, next: () => void): void {
//         // Make this more sophisticated
//         if (this._maintenanceEnabled) {
//             res.header('Retry-After', 3600);
//             res.json(503);
//         } else next();
//     }
    
//     /**
//      * Closes this endpoint and the REST server (service) that was opened earlier.
//      * 
//      * @param correlationId     (optional) transaction id to trace execution through call chain.
//      * @param callback          (optional) the function to call once the closing process is complete.
//      *                          Will be called with an error if one is raised.
//      */
//     public close(correlationId: string, callback?: (err: any) => void): void {
//         if (this._server != null) {
//             // Eat exceptions
//             try {
//                 this._server.close();
//                 this._logger.debug(correlationId, "Closed REST service at %s", this._uri);
//             } catch (ex) {
//                 this._logger.warn(correlationId, "Failed while closing REST service: %s", ex);
//             }

//             this._server = null;
//             this._uri = null;
//         }

//         callback(null);
//     }

//     /**
//      * Registers a registerable object for dynamic endpoint discovery.
//      * 
//      * @param registration      the registration to add. 
//      * 
//      * @see [[IRegisterable]]
//      */
//     public register(registration: IRegisterable): void {
//         this._registrations.push(registration);
//     }

//     /**
//      * Unregisters a registerable object, so that it is no longer used in dynamic 
//      * endpoint discovery.
//      * 
//      * @param registration      the registration to remove. 
//      * 
//      * @see [[IRegisterable]]
//      */
//     public unregister(registration: IRegisterable): void {
//         this._registrations = _.remove(this._registrations, r => r == registration);
//     }

//     private performRegistrations(): void {
//         for (let registration of this._registrations) {
//             registration.register();
//         }
//     }

//     private fixRoute(route: string): string {
//         if (route && route.length > 0 && !route.startsWith("/"))
//             route = "/" + route;
//         return route;
//     }

//     /**
//      * Registers an action in this objects REST server (service) by the given method and route.
//      * 
//      * @param method        the HTTP method of the route.
//      * @param route         the route to register in this object's REST server (service).
//      * @param schema        the schema to use for parameter validation.
//      * @param action        the action to perform at the given route.
//      */
//     public registerRoute(method: string, route: string, schema: Schema,
//         action: (req: any, res: any) => void): void {
//         method = method.toLowerCase();
//         if (method == 'delete') method = 'del';

//         route = this.fixRoute(route);

//         // Hack!!! Wrapping action to preserve prototyping context
//         let actionCurl = (req, res) => { 
//             // Perform validation
//             if (schema != null) {
//                 let params = _.extend({}, req.params, { body: req.body });
//                 let correlationId = params.correlaton_id;
//                 let err = schema.validateAndReturnException(correlationId, params, false);
//                 if (err != null) {
//                     HttpResponseSender.sendError(req, res, err);
//                     return;
//                 }
//             }

//             // Todo: perform verification?
//             action(req, res); 
//         };

//         // Wrapping to preserve "this"
//         let self = this;
//         this._server[method](route, actionCurl);
//     }   
    
//     /**
//      * Registers an action with authorization in this objects REST server (service)
//      * by the given method and route.
//      * 
//      * @param method        the HTTP method of the route.
//      * @param route         the route to register in this object's REST server (service).
//      * @param schema        the schema to use for parameter validation.
//      * @param authorize     the authorization interceptor
//      * @param action        the action to perform at the given route.
//      */
//     public registerRouteWithAuth(method: string, route: string, schema: Schema,
//         authorize: (req: any, res: any, next: () => void) => void,
//         action: (req: any, res: any) => void): void {
            
//         if (authorize) {
//             let nextAction = action;
//             action = (req, res) => {
//                 authorize(req, res, () => { nextAction(req, res); });
//             }
//         }

//         this.registerRoute(method, route, schema, action);
//     }   

//     /**
//      * Registers a middleware action for the given route.
//      * 
//      * @param route         the route to register in this object's REST server (service).
//      * @param action        the middleware action to perform at the given route.
//      */
//     public registerInterceptor(route: string,
//         action: (req: any, res: any, next: () => void) => void): void {

//         route = this.fixRoute(route);

//         this._server.use((req, res, next) => {
//             if (route != null && route != "" && !req.url.startsWith(route))
//                 next();
//             else action(req, res, next);
//         });
//     }

// }
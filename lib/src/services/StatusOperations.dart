//  @module services 
// import { ContextInfo } from 'pip-services3-components-node';
// import { Descriptor } from 'pip-services3-commons-node';
// import { IReferences } from 'pip-services3-commons-node';
// import { StringConverter } from 'pip-services3-commons-node';
// import { ConfigParams } from 'pip-services3-commons-node';

// import { RestOperations } from './RestOperations';

// export class StatusOperations extends RestOperations {
//     private _startTime: Date = new Date();
//     private _references2: IReferences;
//     private _contextInfo: ContextInfo;

//     public constructor() {
//         super();
//         this._dependencyResolver.put("context-info", new Descriptor("pip-services", "context-info", "default", "*", "1.0"));
//     }

//     
// 	/// Sets references to dependent components.
// 	/// 
// 	/// - references 	references to locate the component dependencies. 
//      
//     public setReferences(references: IReferences): void {
//         this._references2 = references;
//         super.setReferences(references);

//         this._contextInfo = this._dependencyResolver.getOneOptional<ContextInfo>("context-info");
//     }

//     public getStatusOperation() {
//         return (req, res) => {
//             this.status(req, res);
//         };
//     }

//     
//     /// Handles status requests
//     /// 
//     /// - req   an HTTP request
//     /// - res   an HTTP response
//      
//     public status(req, res): void {
//         var id = this._contextInfo != null ? this._contextInfo.contextId : "";
//         var name = this._contextInfo != null ? this._contextInfo.name : "Unknown";
//         var description = this._contextInfo != null ? this._contextInfo.description : "";
//         var uptime = new Date().getTime() - this._startTime.getTime();
//         var properties = this._contextInfo != null ? this._contextInfo.properties : "";

//         var components = [];
//         if (this._references2 != null) {
//             for (var locator of this._references2.getAllLocators())
//                 components.push(locator.toString());
//         }

//         var status =  {
//             id: id,
//             name: name,
//             description: description,
//             start_time: StringConverter.toString(this._startTime),
//             current_time: StringConverter.toString(new Date()),
//             uptime: uptime,
//             properties: properties,
//             components: components
//         };

//         this.sendResult(req, res)(null, status);
//     }
// }
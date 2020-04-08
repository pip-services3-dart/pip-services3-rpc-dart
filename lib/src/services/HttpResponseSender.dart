// /** @module services */
// /** @hidden */
// let _ = require('lodash');

// import { ApplicationException } from 'pip-services3-commons-node';

// /**
//  * Helper class that handles HTTP-based responses.
//  */
// export class HttpResponseSender {
//     /**
//      * Sends error serialized as ErrorDescription object
//      * and appropriate HTTP status code.
//      * If status code is not defined, it uses 500 status code.
//      * 
//      * @param req       a HTTP request object.
//      * @param res       a HTTP response object.
//      * @param error     an error object to be sent.
//      */
//     public static sendError(req: any, res: any, error: any): void {
//         error = error || {};
//         error = ApplicationException.unwrapError(error);
        
//         let result = _.pick(error, 'code', 'status', 'name', 'details', 'component', 'message', 'stack', 'cause');
//         result = _.defaults(result, { code: 'Undefined', status: 500, message: 'Unknown error' });

//         res.status(result.status);
//         res.json(result);
//     }

//     /**
//      * Creates a callback function that sends result as JSON object.
//      * That callack function call be called directly or passed
//      * as a parameter to business logic components.
//      * 
//      * If object is not null it returns 200 status code.
//      * For null results it returns 204 status code.
//      * If error occur it sends ErrorDescription with approproate status code.
//      * 
//      * @param req       a HTTP request object.
//      * @param res       a HTTP response object.
//      * @param callback function that receives execution result or error.
//      */
//     public static sendResult(req: any, res: any): (err: any, result: any) => void {
//         return function (err, result) {
//             if (err) {
//                 HttpResponseSender.sendError(req, res, err);
//                 return;
//             }
//             if (result == null) res.send(204);
//             else res.json(result);
//         }
//     }

//     /**
//      * Creates a callback function that sends an empty result with 204 status code.
//      * If error occur it sends ErrorDescription with approproate status code.
//      * 
//      * @param req       a HTTP request object.
//      * @param res       a HTTP response object.
//      * @param callback function that receives error or null for success.
//      */
//     public static sendEmptyResult(req: any, res: any): (err: any) => void {
//         return function (err) {
//             if (err) {
//                 HttpResponseSender.sendError(req, res, err);
//                 return;
//             }
//             res.send(204);
//         }
//     }

//     /**
//      * Creates a callback function that sends newly created object as JSON.
//      * That callack function call be called directly or passed
//      * as a parameter to business logic components.
//      * 
//      * If object is not null it returns 201 status code.
//      * For null results it returns 204 status code.
//      * If error occur it sends ErrorDescription with approproate status code.
//      * 
//      * @param req       a HTTP request object.
//      * @param res       a HTTP response object.
//      * @param callback function that receives execution result or error.
//      */
//     public static sendCreatedResult(req: any, res: any): (err: any, result: any) => void {
//         return function (err, result) {
//             if (err) {
//                 HttpResponseSender.sendError(req, res, err);
//                 return;
//             }
//             if (result == null) res.status(204)
//             else {
//                 res.status(201)
//                 res.json(result);
//             }
//         }
//     }

//     /**
//      * Creates a callback function that sends deleted object as JSON.
//      * That callack function call be called directly or passed
//      * as a parameter to business logic components.
//      * 
//      * If object is not null it returns 200 status code.
//      * For null results it returns 204 status code.
//      * If error occur it sends ErrorDescription with approproate status code.
//      * 
//      * @param req       a HTTP request object.
//      * @param res       a HTTP response object.
//      * @param callback function that receives execution result or error.
//      */
//     public static sendDeletedResult(req: any, res: any): (err: any, result: any) => void {
//         return function (err, result) {
//             if (err) {
//                 HttpResponseSender.sendError(req, res, err);
//                 return;
//             }
//             if (result == null) res.status(204)
//             else {
//                 res.status(200)
//                 res.json(result);
//             }
//         }
//     }
// }

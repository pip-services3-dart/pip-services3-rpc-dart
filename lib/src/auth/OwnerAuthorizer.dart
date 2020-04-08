//  @module auth 
// const _ = require('lodash');

// import { UnauthorizedException } from 'pip-services3-commons-node';
// import { HttpResponseSender } from '../services/HttpResponseSender';

// export class OwnerAuthorizer {

//     public owner(idParam: string = 'user_id'): (req: any, res: any, next: () => void) => void {
//         return (req, res, next) => {
//             if (req.user == null) {
//                 HttpResponseSender.sendError(
//                     req, res,
//                     new UnauthorizedException(
//                         null, 'NOT_SIGNED',
//                         'User must be signed in to perform this operation'
//                     ).withStatus(401)
//                 );
//             } else {
//                 var userId = req.params[idParam] || req.param(idParam);
//                 if (req.user_id != userId) {
//                     HttpResponseSender.sendError(
//                         req, res,
//                         new UnauthorizedException(
//                             null, 'FORBIDDEN',
//                             'Only data owner can perform this operation'
//                         ).withStatus(403)
//                     );
//                 } else {
//                     next();
//                 }
//             }
//         };
//     }

//     public ownerOrAdmin(idParam: string = 'user_id'): (req: any, res: any, next: () => void) => void {
//         return (req, res, next) => {
//             if (req.user == null) {
//                 HttpResponseSender.sendError(
//                     req, res,
//                     new UnauthorizedException(
//                         null, 'NOT_SIGNED',
//                         'User must be signed in to perform this operation'
//                     ).withStatus(401)
//                 );
//             } else {
//                 var userId = req.params[idParam] || req.param(idParam);
//                 var roles = req.user != null ? req.user.roles : null;
//                 var admin = _.includes(roles, 'admin');
//                 if (req.user_id != userId && !admin) {
//                     HttpResponseSender.sendError(
//                         req, res,
//                         new UnauthorizedException(
//                             null, 'FORBIDDEN',
//                             'Only data owner can perform this operation'
//                         ).withStatus(403)
//                     );
//                 } else {
//                     next();
//                 }
//             }
//         };
//     }

// }

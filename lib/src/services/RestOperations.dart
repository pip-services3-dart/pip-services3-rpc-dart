//  @module services 
// const _ = require('lodash');

// import { IConfigurable } from 'pip-services3-commons-node';
// import { ConfigParams } from 'pip-services3-commons-node';
// import { IReferences } from 'pip-services3-commons-node';
// import { IReferenceable } from 'pip-services3-commons-node';
// import { FilterParams } from 'pip-services3-commons-node';
// import { PagingParams } from 'pip-services3-commons-node';
// import { CompositeLogger } from 'pip-services3-components-node';
// import { CompositeCounters } from 'pip-services3-components-node';
// import { DependencyResolver } from 'pip-services3-commons-node';
// import { BadRequestException } from 'pip-services3-commons-node';
// import { UnauthorizedException } from 'pip-services3-commons-node';
// import { NotFoundException } from 'pip-services3-commons-node';
// import { ConflictException } from 'pip-services3-commons-node';
// import { UnknownException } from 'pip-services3-commons-node';
// import { HttpResponseSender } from './HttpResponseSender';

// export abstract class RestOperations implements IConfigurable, IReferenceable {
//     protected _logger = new CompositeLogger();
//     protected _counters = new CompositeCounters();
//     protected _dependencyResolver = new DependencyResolver();

//     public constructor() {}

//     public configure(config: ConfigParams): void {
//         this._dependencyResolver.configure(config);
//     }

//     public setReferences(references: IReferences): void {
//         this._logger.setReferences(references);
//         this._counters.setReferences(references);
//         this._dependencyResolver.setReferences(references);
//     }

//     protected getCorrelationId(req: any): any {
//         return req.params.correlation_id;
//     }

//     protected getFilterParams(req: any): FilterParams {
//         var filter = FilterParams.fromValue(
//             _.omit(req.query, 'skip', 'take', 'total')
//         );
//         return filter;
//     }

//     protected getPagingParams(req: any): PagingParams {
//         var paging = PagingParams.fromValue(
//             _.pick(req.query, 'skip', 'take', 'total')
//         );
//         return paging;
//     }

//     protected sendResult(req, res): (err: any, result: any) => void {
//         return HttpResponseSender.sendResult(req, res);
//     }

//     protected sendEmptyResult(req, res): (err: any) => void {
//         return HttpResponseSender.sendEmptyResult(req, res);
//     }

//     protected sendCreatedResult(req, res): (err: any, result: any) => void {
//         return HttpResponseSender.sendCreatedResult(req, res);
//     }

//     protected sendDeletedResult(req, res): (err: any, result: any) => void {
//         return HttpResponseSender.sendDeletedResult(req, res);
//     }

//     protected sendError(req, res, error): void {
//         HttpResponseSender.sendError(req, res, error);
//     }

//     protected sendBadRequest(req: any, res: any, message: string): void {
//         var correlationId = this.getCorrelationId(req);
//         var error = new BadRequestException(correlationId, 'BAD_REQUEST', message);
//         this.sendError(req, res, error);
//     }

//     protected sendUnauthorized(req: any, res: any, message: string): void  {
//         var correlationId = this.getCorrelationId(req);
//         var error = new UnauthorizedException(correlationId, 'UNAUTHORIZED', message);
//         this.sendError(req, res, error);
//     }

//     protected sendNotFound(req: any, res: any, message: string): void  {
//         var correlationId = this.getCorrelationId(req);
//         var error = new NotFoundException(correlationId, 'NOT_FOUND', message);
//         this.sendError(req, res, error);
//     }

//     protected sendConflict(req: any, res: any, message: string): void  {
//         var correlationId = this.getCorrelationId(req);
//         var error = new ConflictException(correlationId, 'CONFLICT', message);
//         this.sendError(req, res, error);
//     }

//     protected sendSessionExpired(req: any, res: any, message: string): void  {
//         var correlationId = this.getCorrelationId(req);
//         var error = new UnknownException(correlationId, 'SESSION_EXPIRED', message);
//         error.status = 440;
//         this.sendError(req, res, error);
//     }

//     protected sendInternalError(req: any, res: any, message: string): void  {
//         var correlationId = this.getCorrelationId(req);
//         var error = new UnknownException(correlationId, 'INTERNAL', message);
//         this.sendError(req, res, error);
//     }

//     protected sendServerUnavailable(req: any, res: any, message: string): void  {
//         var correlationId = this.getCorrelationId(req);
//         var error = new ConflictException(correlationId, 'SERVER_UNAVAILABLE', message);
//         error.status = 503;
//         this.sendError(req, res, error);
//     }

//     public invoke(operation: string): (req: any, res: any) => void {
//         return (req, res) => {
//             this[operation](req, res);
//         }
//     }

// }
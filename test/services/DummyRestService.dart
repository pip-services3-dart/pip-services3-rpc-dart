// import { IReferences } from 'pip-services3-commons-node';
// import { Descriptor } from 'pip-services3-commons-node';
// import { FilterParams } from 'pip-services3-commons-node';
// import { PagingParams } from 'pip-services3-commons-node';
// import { ObjectSchema } from 'pip-services3-commons-node';
// import { TypeCode } from 'pip-services3-commons-node';
// import { FilterParamsSchema } from 'pip-services3-commons-node';

// import { DummySchema } from '../DummySchema';
// import { RestService } from '../../src/services/RestService';
// import { IDummyController } from '../IDummyController';

// export class DummyRestService extends RestService {
//     private _controller: IDummyController;
//     private _numberOfCalls: number = 0;
	
//     public constructor() {
//         super();
//         this._dependencyResolver.put('controller', new Descriptor("pip-services-dummies", "controller", "default", "*", "*"));
//     }

// 	public setReferences(references: IReferences): void {
// 		super.setReferences(references);
//         this._controller = this._dependencyResolver.getOneRequired<IDummyController>('controller');
//     }
    
//     public getNumberOfCalls(): number {
//         return this._numberOfCalls;
//     }

//     private incrementNumberOfCalls(req: any, res: any, next: () => void) {
//         this._numberOfCalls++;
//         next();
//     }

//     private getPageByFilter(req: any, res: any) {
//         this._controller.getPageByFilter(
//             req.params.correlation_id,
//             new FilterParams(req.params),
//             new PagingParams(req.params),
//             this.sendResult(req, res)
//         );
//     }

//     private getOneById(req, res) {
//         this._controller.getOneById(
//             req.params.correlation_id,
//             req.params.dummy_id,
//             this.sendResult(req, res)
//         );
//     }

//     private create(req, res) {
//         this._controller.create(
//             req.params.correlation_id,
//             req.body,
//             this.sendCreatedResult(req, res)
//         );
//     }

//     private update(req, res) {
//         this._controller.update(
//             req.params.correlation_id,
//             req.body,
//             this.sendResult(req, res)
//         );
//     }

//     private deleteById(req, res) {
//         this._controller.deleteById(
//             req.params.correlation_id,
//             req.params.dummy_id,
//             this.sendDeletedResult(req, res)
//         );
//     }    
        
//     public register() {
//         this.registerInterceptor('/dummies', this.incrementNumberOfCalls);

//         this.registerRoute(
//             'get', '/dummies', 
//             new ObjectSchema(true)
//                 .withOptionalProperty("skip", TypeCode.String)
//                 .withOptionalProperty("take", TypeCode.String)
//                 .withOptionalProperty("total", TypeCode.String)
//                 .withOptionalProperty("body", new FilterParamsSchema()),
//             this.getPageByFilter
//         );

//         this.registerRoute(
//             'get', '/dummies/:dummy_id', 
//             new ObjectSchema(true)
//                 .withRequiredProperty("dummy_id", TypeCode.String),
//             this.getOneById
//         );

//         this.registerRoute(
//             'post', '/dummies', 
//             new ObjectSchema(true)
//                 .withRequiredProperty("body", new DummySchema()),
//             this.create
//         );

//         this.registerRoute(
//             'put', '/dummies', 
//             new ObjectSchema(true)
//                 .withRequiredProperty("body", new DummySchema()),
//             this.update
//         );

//         this.registerRoute(
//             'delete', '/dummies/:dummy_id', 
//             new ObjectSchema(true)
//                 .withRequiredProperty("dummy_id", TypeCode.String),
//             this.deleteById
//         );
//     }
// }

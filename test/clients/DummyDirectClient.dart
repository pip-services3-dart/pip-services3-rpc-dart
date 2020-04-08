// import {
//     Descriptor,
//     FilterParams,
//     PagingParams,
//     DataPage
// } from 'pip-services3-commons-node';

// import { DirectClient } from '../../src/clients/DirectClient';
// import { IDummyClient } from './IDummyClient';
// import { IDummyController } from '../IDummyController';
// import { Dummy } from '../Dummy';

// export class DummyDirectClient extends DirectClient<IDummyController> implements IDummyClient {
            
//     public constructor() {
//         super();

//         this._dependencyResolver.put('controller', new Descriptor("pip-services-dummies", "controller", "*", "*", "*"))
//     }

//     public getDummies(correlationId: string, filter: FilterParams, paging: PagingParams,
//         callback: (err: any, result: DataPage<Dummy>) => void): void {

//         let timing = this.instrument(correlationId, 'dummy.get_page_by_filter');
//         this._controller.getPageByFilter(
//             correlationId, 
//             filter,
//             paging,
//             (err, result) => {
//                 timing.endTiming()
//                 callback(err, result);
//             }
//         );
//     }

//     public getDummyById(correlationId: string, dummyId: string, callback: (err: any, result: Dummy) => void): void {
//         let timing = this.instrument(correlationId, 'dummy.get_one_by_id');
//         this._controller.getOneById(
//             correlationId,
//             dummyId, 
//             (err, result) => {
//                 timing.endTiming();
//                 callback(err, result);
//             }
//         );        
//     }

//     public createDummy(correlationId: string, dummy: any, 
//         callback: (err: any, result: Dummy) => void): void {
        
//         let timing = this.instrument(correlationId, 'dummy.create');
//         this._controller.create(
//             correlationId,
//             dummy, 
//             (err, result) => {
//                 timing.endTiming();
//                 callback(err, result);
//             }
//         );
//     }

//     public updateDummy(correlationId: string, dummy: any, 
//         callback: (err: any, result: Dummy) => void): void {
        
//         let timing = this.instrument(correlationId, 'dummy.update');
//         this._controller.update(
//             correlationId, 
//             dummy, 
//             (err, result) => {
//                 timing.endTiming();
//                 callback(err, result);
//             }
//         );
//     }

//     public deleteDummy(correlationId: string, dummyId: string, 
//         callback: (err: any, result: Dummy) => void): void {
        
//         let timing = this.instrument(correlationId, 'dummy.delete_by_id');
//         this._controller.deleteById(
//             correlationId, 
//             dummyId,
//             (err, result) => {
//                 timing.endTiming();
//                 callback(err, result);
//             }
//         );
//     }
  
// }

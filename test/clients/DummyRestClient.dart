// import { FilterParams } from 'pip-services3-commons-node';
// import { PagingParams } from 'pip-services3-commons-node';
// import { DataPage } from 'pip-services3-commons-node';

// import { RestClient } from '../../src/clients/RestClient';
// import { IDummyClient } from './IDummyClient';
// import { Dummy } from '../Dummy';

// export class DummyRestClient extends RestClient implements IDummyClient {
        
//     public getDummies(correlationId: string, filter: FilterParams, paging: PagingParams, callback: (err: any, result: DataPage<Dummy>) => void): void {
//         let params = {};
//         this.addFilterParams(params, filter);
//         this.addPagingParams(params, paging);

//         this.call('get', 
//             '/dummies',
//             correlationId, 
//             params,
//             (err, result) => {
//                 this.instrument(correlationId, 'dummy.get_page_by_filter');
//                 callback(err, result);
//             }
//         );
//     }

//     public getDummyById(correlationId: string, dummyId: string, callback: (err: any, result: Dummy) => void): void {
//         this.call('get', 
//             '/dummies/' + dummyId,
//             correlationId,
//             {}, 
//             (err, result) => {
//                 this.instrument(correlationId, 'dummy.get_one_by_id');
//                 callback(err, result);
//             }
//         );        
//     }

//     public createDummy(correlationId: string, dummy: any, callback: (err: any, result: Dummy) => void): void {
//         this.call('post', 
//             '/dummies',
//             correlationId,
//             {}, 
//             dummy, 
//             (err, result) => {
//                 this.instrument(correlationId, 'dummy.create');
//                 callback(err, result);
//             }
//         );
//     }

//     public updateDummy(correlationId: string, dummy: any, callback: (err: any, result: Dummy) => void): void {
//         this.call('put', 
//             '/dummies',
//             correlationId, 
//             {}, 
//             dummy, 
//             (err, result) => {
//                 this.instrument(correlationId, 'dummy.update');
//                 callback(err, result);
//             }
//         );
//     }

//     public deleteDummy(correlationId: string, dummyId: string, callback: (err: any, result: Dummy) => void): void {
//         this.call('delete', 
//             '/dummies/' + dummyId,
//             correlationId, 
//             {}, 
//             (err, result) => {
//                 this.instrument(correlationId, 'dummy.delete_by_id');
//                 callback(err, result);
//             }
//         );
//     }
  
// }

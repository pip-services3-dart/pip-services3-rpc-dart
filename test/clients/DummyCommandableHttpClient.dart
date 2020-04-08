// import {
//     FilterParams,
//     PagingParams,
//     DataPage
// } from 'pip-services3-commons-node';

// import { CommandableHttpClient } from '../../src/clients/CommandableHttpClient';
// import { IDummyClient } from './IDummyClient';
// import { Dummy } from '../Dummy';

// export class DummyCommandableHttpClient extends CommandableHttpClient implements IDummyClient {
        
//     public constructor() {
//         super('dummy');
//     }

//     public getDummies(String correlationId, filter: FilterParams, paging: PagingParams, callback: (err: any, result: DataPage<Dummy>) => void): void {
//         this.callCommand(
//             'get_dummies', 
//             correlationId, 
//             {
//                 filter: filter,
//                 paging: paging
//             },
//             callback
//         );
//     }

//     public getDummyById(String correlationId, dummyId: string, callback: (err: any, result: Dummy) => void): void {
//         this.callCommand(
//             'get_dummy_by_id', 
//             correlationId,
//             {
//                 dummy_id: dummyId
//             }, 
//             callback
//         );        
//     }

//     public createDummy(String correlationId, dummy: any, callback: (err: any, result: Dummy) => void): void {
//         this.callCommand(
//             'create_dummy',
//             correlationId,
//             {
//                 dummy: dummy
//             }, 
//             callback
//         );
//     }

//     public updateDummy(String correlationId, dummy: any, callback: (err: any, result: Dummy) => void): void {
//         this.callCommand(
//             'update_dummy',
//             correlationId,
//             {
//                 dummy: dummy
//             }, 
//             callback
//         );
//     }

//     public deleteDummy(String correlationId, dummyId: string, callback: (err: any, result: Dummy) => void): void {
//         this.callCommand(
//             'delete_dummy',
//             correlationId, 
//             {
//                 dummy_id: dummyId
//             },
//             callback
//         );
//     }
  
// }

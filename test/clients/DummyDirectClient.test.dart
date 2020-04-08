// var assert = require('chai').assert;
// var async = require('async');

// import {
//     Descriptor,
//     References,
//     FilterParams,
//     PagingParams
// } from 'pip-services3-commons-node';

// import { Dummy } from '../Dummy';
// import { DummyController } from '../DummyController';
// import { DummyDirectClient } from './DummyDirectClient';

// suite('DummyDirectClient', ()=> {
//     var _dummy1: Dummy;
//     var _dummy2: Dummy;

//     var client: DummyDirectClient;

//     suiteSetup((done) => {
//         var ctrl = new DummyController();

//         client = new DummyDirectClient();

//         var references: References = References.fromTuples(
//             new Descriptor('pip-services-dummies', 'controller', 'default', 'default', '1.0'), ctrl
//         );
//         client.setReferences(references);

//         client.open(null, done);
//     });
    
//     suiteTeardown((done) => {
//         client.close(null, done);
//     });

//     setup(() => {
//         _dummy1 = { id: null, key: "Key 1", content: "Content 1"};
//         _dummy2 = { id: null, key: "Key 2", content: "Content 2"};
//     });

//     test('CRUD Operations', (done) => {
//         var dummy1, dummy2;

//         async.series([
//         // Create one dummy
//             (callback) => {
//                 client.createDummy(
//                     null,
//                     _dummy1,
//                     (err, dummy) => {
//                         assert.isNull(err);
                        
//                         assert.isObject(dummy);
//                         assert.equal(dummy.content, _dummy1.content);
//                         assert.equal(dummy.key, _dummy1.key);

//                         dummy1 = dummy;

//                         callback();
//                     }
//                 );
//             },
//         // Create another dummy
//             (callback) => {
//                 client.createDummy(
//                     null,
//                     _dummy2,
//                     (err, dummy) => {
//                         assert.isNull(err);
                        
//                         assert.isObject(dummy);
//                         assert.equal(dummy.content, _dummy2.content);
//                         assert.equal(dummy.key, _dummy2.key);

//                         dummy2 = dummy;

//                         callback();
//                     }
//                 );
//             },
//         // Get all dummies
//             (callback) => {
//                 client.getDummies(
//                     null,
//                     new FilterParams(),
//                     new PagingParams(0,5,false),
//                     (err, dummies) => {
//                         assert.isNull(err);
                        
//                         assert.isObject(dummies);
//                         assert.isTrue(dummies.data.length >= 2);

//                         callback();
//                     }
//                 );
//             },
//         // Update the dummy
//             (callback) => {
//                 dummy1.content = 'Updated Content 1';
//                 client.updateDummy(
//                     null,
//                     dummy1,
//                     (err, dummy) => {
//                         assert.isNull(err);
                        
//                         assert.isObject(dummy);
//                         assert.equal(dummy.content, 'Updated Content 1');
//                         assert.equal(dummy.key, _dummy1.key);

//                         dummy1 = dummy;

//                         callback();
//                     }
//                 );
//             },
//         // Delete dummy
//             (callback) => {
//                 client.deleteDummy(
//                     null,
//                     dummy1.id,
//                     (err) => {
//                         assert.isNull(err);

//                         callback();
//                     }
//                 );
//             },
//         // Try to get delete dummy
//             (callback) => {
//                 client.getDummyById(
//                     null,
//                     dummy1.id,
//                     (err, dummy) => {
//                         assert.isNull(err);
                        
//                         assert.isNull(dummy || null);

//                         callback();
//                     }
//                 );
//             }
//         ], done);
//     });

// });

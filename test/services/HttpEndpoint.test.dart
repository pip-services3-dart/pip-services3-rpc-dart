// var assert = require('chai').assert;
// var restify = require('restify-clients');
// var async = require('async');

// import { Descriptor } from 'pip-services3-commons-node';
// import { ConfigParams } from 'pip-services3-commons-node';
// import { References } from 'pip-services3-commons-node';

// import { HttpEndpoint } from '../../src/services/HttpEndpoint';
// import { Dummy } from '../Dummy';
// import { DummyController } from '../DummyController';
// import { DummyRestService } from './DummyRestService';

// var restConfig = ConfigParams.fromTuples(
//     "connection.protocol", "http",
//     "connection.host", "localhost",
//     "connection.port", 3000
// );

// suite('HttpEndpoint', ()=> {
//     var _dummy1: Dummy;
//     var _dummy2: Dummy;

//     var endpoint: HttpEndpoint;
//     var service: DummyRestService;

//     var rest: any;

//     suiteSetup((done) => {
//         var ctrl = new DummyController();

//         service = new DummyRestService();
//         service.configure(ConfigParams.fromTuples(
//             'base_route', '/api/v1'
//         ));

//         endpoint = new HttpEndpoint();
//         endpoint.configure(restConfig);

//         var references: References = References.fromTuples(
//             new Descriptor('pip-services-dummies', 'controller', 'default', 'default', '1.0'), ctrl,
//             new Descriptor('pip-services-dummies', 'service', 'rest', 'default', '1.0'), service,
//             new Descriptor('pip-services', 'endpoint', 'http', 'default', '1.0'), endpoint
//         );
//         service.setReferences(references);

//         endpoint.open(null, (err) => {
//             if (err) done(err);
//             else service.open(null, done);
//         });
//     });
    
//     suiteTeardown((done) => {
//         service.close(null, (err) => {
//             if (err) done(err);
//             else endpoint.close(null, done);
//         });
//     });

//     setup(() => {
//         var url = 'http://localhost:3000';
//         rest = restify.createJsonClient({ url: url, version: '*' });

//         _dummy1 = { id: null, key: "Key 1", content: "Content 1"};
//         _dummy2 = { id: null, key: "Key 2", content: "Content 2"};
//     });

//     test('CRUD Operations', (done) => {
//         rest.get('/api/v1/dummies',
//             (err, req, res, dummies) => {
//                 assert.isNull(err);
                
//                 assert.isObject(dummies);
//                 assert.lengthOf(dummies.data, 0);

//                 done();
//             }
//         );
//     });

// });

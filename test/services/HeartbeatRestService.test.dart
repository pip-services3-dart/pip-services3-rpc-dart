// var assert = require('chai').assert;
// var restify = require('restify-clients');

// import { ConfigParams } from 'pip-services3-commons-node';

// import { HeartbeatRestService } from '../../src/services/HeartbeatRestService';

// var restConfig = ConfigParams.fromTuples(
//     "connection.protocol", "http",
//     "connection.host", "localhost",
//     "connection.port", 3000
// );

// suite('HeartbeatRestService', ()=> {
//     var service: HeartbeatRestService;
//     var rest: any;

//     suiteSetup((done) => {
//         service = new HeartbeatRestService();
//         service.configure(restConfig);

//         service.open(null, done);
//     });
    
//     suiteTeardown((done) => {
//         service.close(null, done);
//     });

//     setup(() => {
//         var url = 'http://localhost:3000';
//         rest = restify.createJsonClient({ url: url, version: '*' });
//     });
    
//     test('Status', (done) => {
//         rest.get('/heartbeat',
//             (err, req, res, result) => {
//                 assert.isNull(err);
                
//                 assert.isNotNull(result);

//                 done();
//             }
//         );
//     });

// });

// var assert = require('chai').assert;
// var restify = require('restify-clients');
// var async = require('async');

// import { Descriptor } from 'pip-services3-commons-node';
// import { ConfigParams } from 'pip-services3-commons-node';
// import { References } from 'pip-services3-commons-node';
// import { ContextInfo } from 'pip-services3-components-node';

// import { StatusRestService } from '../../src/services/StatusRestService';

// var restConfig = ConfigParams.fromTuples(
//     "connection.protocol", "http",
//     "connection.host", "localhost",
//     "connection.port", 3000
// );

// suite('StatusRestService', ()=> {
//     var service: StatusRestService;
//     var rest: any;

//     suiteSetup((done) => {
//         service = new StatusRestService();
//         service.configure(restConfig);

//         var contextInfo = new ContextInfo();
//         contextInfo.name = "Test";
//         contextInfo.description = "This is a test container";

//         var references = References.fromTuples(
//             new Descriptor("pip-services", "context-info", "default", "default", "1.0"), contextInfo,
//             new Descriptor("pip-services", "status-service", "http", "default", "1.0"), service
//         );
//         service.setReferences(references);

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
//         rest.get('/status',
//             (err, req, res, result) => {
//                 assert.isNull(err);
                
//                 assert.isNotNull(result);

//                 done();
//             }
//         );
//     });

// });

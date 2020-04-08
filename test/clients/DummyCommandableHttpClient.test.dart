// var assert = require('chai').assert;
// var restify = require('restify');
// var async = require('async');

// import {
//     Descriptor,
//     ConfigParams,
//     References
// } from 'pip-services3-commons-node';

// import { Dummy } from '../Dummy';
// import { DummyController } from '../DummyController';
// import { DummyCommandableHttpService } from '../services/DummyCommandableHttpService';
// import { DummyCommandableHttpClient } from './DummyCommandableHttpClient';
// import { DummyClientFixture } from './DummyClientFixture';

// var restConfig = ConfigParams.fromTuples(
//     "connection.protocol", "http",
//     "connection.host", "localhost",
//     "connection.port", 3000
// );

// suite('DummyCommandableHttpClient', ()=> {
//     var service: DummyCommandableHttpService;
//     var client: DummyCommandableHttpClient;

//     var rest: any;
//     var fixture: DummyClientFixture;

//     suiteSetup((done) => {
//         var ctrl = new DummyController();

//         service = new DummyCommandableHttpService();
//         service.configure(restConfig);

//         var references: References = References.fromTuples(
//             new Descriptor('pip-services-dummies', 'controller', 'default', 'default', '1.0'), ctrl,
//             new Descriptor('pip-services-dummies', 'service', 'http', 'default', '1.0'), service
//         );
//         service.setReferences(references);

//         service.open(null, done);
//     });
    
//     suiteTeardown((done) => {
//         service.close(null, done);
//     });

//     setup((done) => {
//         client = new DummyCommandableHttpClient();
//         fixture = new DummyClientFixture(client);

//         client.configure(restConfig);
//         client.setReferences(new References());
//         client.open(null, done);
//     });

//     test('CRUD Operations', (done) => {
//         fixture.testCrudOperations(done);
//     });

// });

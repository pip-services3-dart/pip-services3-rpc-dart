// var assert = require('chai').assert;

// import { ConfigParams } from 'pip-services3-commons-node';
// import { References } from 'pip-services3-commons-node';

// import { DummyRestClient } from './DummyRestClient';

// var restConfig = ConfigParams.fromTuples(
//     "connection.protocol", "http",
//     "connection.host", "localhost",
//     "connection.port", 12345,

//     "options.retries", 2,
//     "options.timeout", 100,
//     "options.connect_timeout", 100
// );

// suite('RetriesRestClient', ()=> {
//     var client: DummyRestClient;

//     var rest: any;

//     setup((done) => {
//         client = new DummyRestClient();

//         client.configure(restConfig);
//         client.setReferences(new References());
//         client.open(null, done);
//     });

//     test('Retry to call non-existing client', (done) => {
//         client.getDummyById(null, '1', (err, result) => {
//             assert.isNotNull(err);
//             done();
//         });
//     });

// });

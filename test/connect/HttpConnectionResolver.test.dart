// let assert = require('chai').assert;

// import {  ConfigParams } from 'pip-services3-commons-node';

// import { HttpConnectionResolver } from '../../src/connect/HttpConnectionResolver';

// suite('HttpConnectionResolver', ()=> {

//     test('Resolve URI', (done) => {
//         let resolver = new HttpConnectionResolver();
//         resolver.configure(ConfigParams.fromTuples(
//             "connection.uri", "http://somewhere.com:777"
//         ));

//         resolver.resolve(null, (err, connection) => {
//             assert.equal("http", connection.getProtocol());
//             assert.equal("somewhere.com", connection.getHost());
//             assert.equal(777, connection.getPort());

//             done();
//         });
//     });

//     test('Resolve Parameters', (done) => {
//         let resolver = new HttpConnectionResolver();
//         resolver.configure(ConfigParams.fromTuples(
//             "connection.protocol", "http",
//             "connection.host", "somewhere.com",
//             "connection.port", 777
//         ));

//         resolver.resolve(null, (err, connection) => {
//             assert.equal("http://somewhere.com:777", connection.getUri());

//             done();
//         });
//     });
    
// });

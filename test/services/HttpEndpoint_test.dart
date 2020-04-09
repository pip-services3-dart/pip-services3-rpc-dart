
import 'package:test/test.dart';

import 'package:pip_services3_commons/pip_services3_commons.dart';


import '../../lib/src/services/HttpEndpoint.dart';
import '../Dummy.dart';
import '../DummyController.dart';
import './DummyRestService.dart';

var restConfig = ConfigParams.fromTuples([
    'connection.protocol', 'http',
    'connection.host', 'localhost',
    'connection.port', 3000
]);

void main(){

group('HttpEndpoint', () {
    Dummy _dummy1;
    Dummy _dummy2;

    HttpEndpoint endpoint ;
    DummyRestService service;

    var rest;

    
        var ctrl = DummyController();

        service = DummyRestService();
        service.configure(ConfigParams.fromTuples([
            'base_route', '/api/v1'
        ]));

        endpoint = HttpEndpoint();
        endpoint.configure(restConfig);

        var references = References.fromTuples([
             Descriptor('pip-services-dummies', 'controller', 'default', 'default', '1.0'), ctrl,
             Descriptor('pip-services-dummies', 'service', 'rest', 'default', '1.0'), service,
             Descriptor('pip-services', 'endpoint', 'http', 'default', '1.0'), endpoint
        ]);
        service.setReferences(references);

        endpoint.open(null) ;
        service.open(null);
       
    
    
    tearDown(()  {
        service.close(null);
        endpoint.close(null);
    });

    setUp(()  {
        var url = 'http://localhost:3000';
        rest = restify.createJsonClient({ url: url, version: '*' });

        _dummy1 = Dummy.from( null, 'Key 1', 'Content 1');
        _dummy2 = Dummy.from(  null,  'Key 2',  'Content 2');
    });

    test('CRUD Operations', ()  {
        rest.get('/api/v1/dummies',
            (err, req, res, dummies)  {
                expect(err, isNull);
                
                expect(dummies, isNotNull);
                expect(dummies.data.length, 0);
            }
        );
    });

});
}
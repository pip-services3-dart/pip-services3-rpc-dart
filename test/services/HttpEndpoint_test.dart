import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';
import '../DummyController.dart';
import './DummyRestService.dart';

var restConfig = ConfigParams.fromTuples([
  'connection.protocol',
  'http',
  'connection.host',
  'localhost',
  'connection.port',
  '3001'
]);

void main() {
  group('HttpEndpoint', () {
    HttpEndpoint endpoint;
    DummyRestService service;

    late http.Client rest;
    late String url;

    var ctrl = DummyController();

    service = DummyRestService();
    service.configure(ConfigParams.fromTuples(['base_route', '/api/v1']));

    endpoint = HttpEndpoint();
    endpoint.configure(restConfig);

    setUpAll(() async {
      var references = References.fromTuples([
        Descriptor(
            'pip-services-dummies', 'controller', 'default', 'default', '1.0'),
        ctrl,
        Descriptor('pip-services-dummies', 'service', 'rest', 'default', '1.0'),
        service,
        Descriptor('pip-services', 'endpoint', 'http', 'default', '1.0'),
        endpoint
      ]);
      service.setReferences(references);

      await endpoint.open(null);
      await service.open(null);

      url = 'http://localhost:3001';
      rest = http.Client();
    });

    tearDownAll(() async {
      await service.close(null);
      await endpoint.close(null);
    });

    test('CRUD Operations', () async {
      var resp = await rest.get(Uri.parse(url + '/api/v1/dummies'));
      var dummies =
          DataPage.fromJson(json.decode(resp.body.toString()), (itemsJson) {
        return Map.from(itemsJson).cast<String, String>();
      });
      expect(dummies, isNotNull);
      expect(dummies.data.length, 0);
    });
  });
}

import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../Dummy.dart';
import '../DummyController.dart';
import '../SubDummy.dart';
import './DummyRestService.dart';

void main() {
  var restConfig = ConfigParams.fromTuples([
    'connection.protocol',
    'http',
    'connection.host',
    'localhost',
    'connection.port',
    3000,
    'swagger.content', 'swagger yaml or json content', // for test only
    'swagger.enable', 'true'
  ]);

  group('DummyRestService', () {
    late Dummy _dummy1;
    late Dummy _dummy2;
    late DummyRestService service;
    late http.Client rest;
    late String url;

    setUpAll(() async {
      var ctrl = DummyController();

      service = DummyRestService();
      service.configure(restConfig);

      var references = References.fromTuples([
        Descriptor(
            'pip-services-dummies', 'controller', 'default', 'default', '1.0'),
        ctrl,
        Descriptor('pip-services-dummies', 'service', 'rest', 'default', '1.0'),
        service
      ]);
      service.setReferences(references);

      await service.open(null);

      url = 'http://localhost:3000';
      rest = http.Client();
    });

    tearDownAll(() async {
      await service.close(null);
    });

    setUp(() {
      _dummy1 = Dummy(
          id: null,
          key: 'Key 1',
          content: 'Content 1',
          array: [SubDummy(key: 'SubKey 1', content: 'SubContent 1')]);

      _dummy2 = Dummy(
          id: null,
          key: 'Key 2',
          content: 'Content 2',
          array: [SubDummy(key: 'SubKey 2', content: 'SubContent 2')]);
    });

    test('CRUD Operations', () async {
      var dummy1;

      // Create one dummy
      var resp = await rest.post(Uri.parse(url + '/dummies'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(_dummy1.toJson()));
      var dummy = Dummy.fromJson(json.decode(resp.body.toString()));
      expect(dummy, isNotNull);
      expect(dummy.content, _dummy1.content);
      expect(dummy.key, _dummy1.key);
      dummy1 = dummy;

      // Create another dummy
      resp = await rest.post(Uri.parse(url + '/dummies'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(_dummy2.toJson()));
      dummy = Dummy.fromJson(json.decode(resp.body.toString()));
      expect(dummy, isNotNull);
      expect(dummy.content, _dummy2.content);
      expect(dummy.key, _dummy2.key);

      // Get all dummies
      resp = await rest.get(Uri.parse(url + '/dummies'));
      var dummies =
          DataPage.fromJson(json.decode(resp.body.toString()), (item) {
        return item;
      });
      expect(dummies, isNotNull);
      expect(dummies.data.length, 2);

      // Update the dummy
      dummy1.content = 'Updated Content 1';

      resp = await rest.put(Uri.parse(url + '/dummies'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(dummy1.toJson()));
      dummy = Dummy.fromJson(json.decode(resp.body.toString()));
      expect(dummy, isNotNull);
      expect(dummy.content, 'Updated Content 1');
      expect(dummy.key, _dummy1.key);

      dummy1 = dummy;

      // Delete dummy
      await rest.delete(Uri.parse(url + '/dummies/' + dummy1.id));

      // Try to get delete dummy
      resp = await rest.get(Uri.parse(url + '/dummies/' + dummy1.id));
      expect(resp.body, isEmpty);
    });

    test('Check correlationId', () async {
      // check transmit correllationId over params
      var resp = await rest.get(Uri.parse(
          url + '/dummies/check/correlation_id?correlation_id=test_cor_id'));
      expect(json.decode(resp.body)['correlation_id'], 'test_cor_id');

      // check transmit correllationId over header
      resp = await rest.get(Uri.parse(url + '/dummies/check/correlation_id'),
          headers: {'correlation_id': 'test_cor_id_header'});
      expect(service.getNumberOfCalls(), 4); // Check interceptor
      expect(json.decode(resp.body)['correlation_id'], 'test_cor_id_header');
    });

    test('Get OpenApi Spec From String', () async {
      var resp = await rest.get(Uri.parse(url + '/swagger'));
      var openApiContent = restConfig.getAsString('swagger.content');
      expect(openApiContent, resp.body);
    });

    test('Get OpenApi Spec From File', () async {
      var openApiContent = 'swagger yaml content from file';
      var filename = 'dummy_' + IdGenerator.nextLong() + '.tmp';

      // create temp file
      var file = File(filename);
      await file.writeAsString(openApiContent);

      // recreate service with new configuration
      await service.close(null);

      var serviceConfig = ConfigParams.fromTuples([
        'connection.protocol', 'http',
        'connection.host', 'localhost',
        'connection.port', 3000,
        'swagger.path', filename, // for test only
        'swagger.enable', 'true'
      ]);

      var ctrl = DummyController();

      service = DummyRestService();
      service.configure(serviceConfig);

      var references = References.fromTuples([
        Descriptor(
            'pip-services-dummies', 'controller', 'default', 'default', '1.0'),
        ctrl,
        Descriptor('pip-services-dummies', 'service', 'rest', 'default', '1.0'),
        service
      ]);
      service.setReferences(references);
      await service.open(null);
      var resp = await rest.get(Uri.parse(url + '/swagger'));
      expect(openApiContent, resp.body);

      // delete temp file
      await file.delete();
    });
  });
}

import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../Dummy.dart';
import '../DummyController.dart';
import '../SubDummy.dart';
import './DummyCommandableHttpService.dart';

var restConfig = ConfigParams.fromTuples([
  'connection.protocol',
  'http',
  'connection.host',
  'localhost',
  'connection.port',
  3000,
  'swagger.enable',
  'true'
]);

void main() {
  group('DummyCommandableHttpService', () {
    late Dummy _dummy1;
    late Dummy _dummy2;

    late DummyCommandableHttpService service;

    late http.Client rest;
    late String url;

    setUpAll(() async {
      var ctrl = DummyController();

      service = DummyCommandableHttpService();
      service.configure(restConfig);

      var references = References.fromTuples([
        Descriptor(
            'pip-services-dummies', 'controller', 'default', 'default', '1.0'),
        ctrl,
        Descriptor('pip-services-dummies', 'service', 'http', 'default', '1.0'),
        service
      ]);
      service.setReferences(references);

      await service.open(null);
      url = 'http://localhost:3000';
    });

    tearDownAll(() async {
      await service.close(null);
    });

    setUp(() {
      rest = http.Client();
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
      var resp = await rest.post(Uri.parse(url + '/dummy/create_dummy'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'dummy': _dummy1}));
      var dummy = Dummy.fromJson(json.decode(resp.body.toString()));
      expect(dummy, isNotNull);
      expect(dummy.content, _dummy1.content);
      expect(dummy.key, _dummy1.key);

      dummy1 = dummy;

      // Create another dummy
      resp = await rest.post(Uri.parse(url + '/dummy/create_dummy'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'dummy': _dummy2}));
      dummy = Dummy.fromJson(json.decode(resp.body.toString()));
      expect(dummy, isNotNull);
      expect(dummy.content, _dummy2.content);
      expect(dummy.key, _dummy2.key);

      // Get all dummies
      resp = await rest.post(Uri.parse(url + '/dummy/get_dummies'));
      var dummies = DataPage<Dummy>.fromJson(
          json.decode(resp.body.toString()), (item) => Dummy.fromJson(item));
      expect(dummies, isNotNull);
      expect(dummies.data.length, 2);

      // Update the dummy
      dummy1.content = 'Updated Content 1';
      resp = await rest.post(Uri.parse(url + '/dummy/update_dummy'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'dummy': dummy1}));
      dummy = Dummy.fromJson(json.decode(resp.body.toString()));
      expect(dummy, isNotNull);
      expect(dummy.content, 'Updated Content 1');
      expect(dummy.key, dummy1.key);

      dummy1 = dummy;

      // Delete dummy
      resp = await rest.post(Uri.parse(url + '/dummy/delete_dummy'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'dummy_id': dummy1.id}));
      dummy = Dummy.fromJson(json.decode(resp.body.toString()));
      expect(dummy.id, dummy1.id);

      // Try to get delete dummy
      resp = await rest.post(Uri.parse(url + '/dummy/get_dummy_by_id'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'dummy_id': dummy1.id}));
      expect(resp.body, isEmpty);
    });

    test('Check correlationId', () async {
      // check transmit correllationId over params
      var resp = await rest.post(Uri.parse(
          url + '/dummy/check_correlation_id?correlation_id=test_cor_id'));
      expect(json.decode(resp.body)['correlation_id'], 'test_cor_id');

      // check transmit correllationId over header
      resp = await rest.post(Uri.parse(url + '/dummy/check_correlation_id'),
          headers: {'correlation_id': 'test_cor_id_header'});
      expect(json.decode(resp.body)['correlation_id'], 'test_cor_id_header');
    });

    test('Get OpenApi Spec', () async {
      var resp = await rest.get(Uri.parse(url + '/dummy/swagger'));
      expect(resp.body.contains('openapi:'), true);
    });

    test('OpenApi Spec Override', () async {
      var openApiContent = 'swagger yaml content';

      // recreate service with new configuration
      await service.close('');

      var config = restConfig
          .setDefaults(ConfigParams.fromTuples(['swagger.auto', false]));

      var ctrl = DummyController();
      service = DummyCommandableHttpService();
      service.configure(config);

      var references = References.fromTuples([
        Descriptor(
            'pip-services-dummies', 'controller', 'default', 'default', '1.0'),
        ctrl,
        Descriptor('pip-services-dummies', 'service', 'http', 'default', '1.0'),
        service
      ]);
      service.setReferences(references);
      await service.open('');
      var resp = await rest.get(Uri.parse(url + '/dummy/swagger'));
      expect(openApiContent, resp.body);
    });
  });
}

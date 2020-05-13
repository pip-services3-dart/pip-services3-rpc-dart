import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../Dummy.dart';
import '../DummyController.dart';
import './DummyCommandableHttpService.dart';

var restConfig = ConfigParams.fromTuples([
  'connection.protocol',
  'http',
  'connection.host',
  'localhost',
  'connection.port',
  3000
]);

void main() {
  group('DummyCommandableHttpService', () {
    Dummy _dummy1;
    Dummy _dummy2;

    DummyCommandableHttpService service;

    http.Client rest;
    String url;

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
      _dummy1 = Dummy(id: null, key: 'Key 1', content: 'Content 1');
      _dummy2 = Dummy(id: null, key: 'Key 2', content: 'Content 2');
    });

    test('CRUD Operations', () async {
      var dummy1;

      // Create one dummy
      var resp = await rest.post(url + '/dummy/create_dummy',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'dummy': _dummy1}));
      var dummy = Dummy.fromJson(json.decode(resp.body.toString()));
      expect(dummy, isNotNull);
      expect(dummy.content, _dummy1.content);
      expect(dummy.key, _dummy1.key);

      dummy1 = dummy;

      // Create another dummy
      resp = await rest.post(url + '/dummy/create_dummy',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'dummy': _dummy2}));
      dummy = Dummy.fromJson(json.decode(resp.body.toString()));
      expect(dummy, isNotNull);
      expect(dummy.content, _dummy2.content);
      expect(dummy.key, _dummy2.key);

      // Get all dummies
      resp = await rest.post(url + '/dummy/get_dummies');
      var dummies = DataPage<Dummy>.fromJson(
          json.decode(resp.body.toString()), (item) => Dummy.fromJson(item));
      expect(dummies, isNotNull);
      expect(dummies.data.length, 2);

      // Update the dummy
      dummy1.content = 'Updated Content 1';
      resp = await rest.post(url + '/dummy/update_dummy',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'dummy': dummy1}));
      dummy = Dummy.fromJson(json.decode(resp.body.toString()));
      expect(dummy, isNotNull);
      expect(dummy.content, 'Updated Content 1');
      expect(dummy.key, dummy1.key);

      dummy1 = dummy;

      // Delete dummy
      resp = await rest.post(url + '/dummy/delete_dummy',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'dummy_id': dummy1.id}));
      dummy = Dummy.fromJson(json.decode(resp.body.toString()));
      expect(dummy.id, dummy1.id);

      // Try to get delete dummy
      resp = await rest.post(url + '/dummy/get_dummy_by_id',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'dummy_id': dummy1.id}));
      expect(resp.body, isEmpty);
    });
  });
}

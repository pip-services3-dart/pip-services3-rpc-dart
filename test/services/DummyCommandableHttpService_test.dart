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
      _dummy1 = Dummy.from(null, 'Key 1', 'Content 1');
      _dummy2 = Dummy.from(null, 'Key 2', 'Content 2');
    });

    test('CRUD Operations', () async {
      var dummy1, dummy2;

      // Create one dummy
      try {
        var resp = await rest.post(url + '/dummy/create_dummy',
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'dummy': _dummy1}));
        var dummy = Dummy.fromJson(json.decode(resp.body.toString()));
        expect(dummy, isNotNull);
        expect(dummy.content, _dummy1.content);
        expect(dummy.key, _dummy1.key);

        dummy1 = dummy;
      } catch (err) {
        expect(err, isNull);
      }

      // Create another dummy
      try {
        var resp = await rest.post(url + '/dummy/create_dummy',
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'dummy': _dummy2}));
        var dummy = Dummy.fromJson(json.decode(resp.body.toString()));
        expect(dummy, isNotNull);
        expect(dummy.content, _dummy2.content);
        expect(dummy.key, _dummy2.key);

        dummy2 = dummy;
      } catch (err) {
        expect(err, isNull);
      }

      // Get all dummies
      try {
        var resp = await rest.post(url + '/dummy/get_dummies');
        var dummies = DataPage<Dummy>.fromJson(
            json.decode(resp.body.toString()), (item) => Dummy.fromJson(item));
        expect(dummies, isNotNull);
        expect(dummies.data.length, 2);
      } catch (err) {
        expect(err, isNull);
      }

      // Update the dummy

      dummy1.content = 'Updated Content 1';
      try {
        var resp = await rest.post(url + '/dummy/update_dummy',
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'dummy': dummy1}));
        var dummy = Dummy.fromJson(json.decode(resp.body.toString()));
        expect(dummy, isNotNull);
        expect(dummy.content, 'Updated Content 1');
        expect(dummy.key, dummy1.key);

        dummy1 = dummy;
      } catch (err) {
        expect(err, isNull);
      }

      // Delete dummy
      try {
        var resp = await rest.post(url + '/dummy/delete_dummy',
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'dummy_id': dummy1.id}));
        var dummy = Dummy.fromJson(json.decode(resp.body.toString()));
        expect(dummy.id, dummy1.id);
      } catch (err) {
        expect(err, isNull);
      }

      // Try to get delete dummy
      try {
        var resp = await rest.post(url + '/dummy/get_dummy_by_id',
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'dummy_id': dummy1.id}));
        expect(resp.body, isEmpty);
      } catch (err) {
        expect(err, isNull);
      }
    });
  });
}
import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../Dummy.dart';
import '../DummyController.dart';
import './DummyRestService.dart';

void main() {
  var restConfig = ConfigParams.fromTuples([
    'connection.protocol',
    'http',
    'connection.host',
    'localhost',
    'connection.port',
    3000
  ]);

  group('DummyRestService', () {
    Dummy _dummy1;
    Dummy _dummy2;
    DummyRestService service;
    http.Client rest;
    String url;

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
      //print('DummyRestService Endpoint closed');
    });

    setUp(() {
      _dummy1 = Dummy.from(null, 'Key 1', 'Content 1');
      _dummy2 = Dummy.from(null, 'Key 2', 'Content 2');
    });

    test('CRUD Operations', () async {
      var dummy1, dummy2;

      // Create one dummy
      try {
        var resp = await rest.post(url + '/dummies',
            headers: {'Content-Type': 'application/json'},
            body: json.encode(_dummy1.toJson()));
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
        var resp = await rest.post(url + '/dummies',
            headers: {'Content-Type': 'application/json'},
            body: json.encode(_dummy2.toJson()));
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
        var resp = await rest.get(url + '/dummies');
        var dummies =
            DataPage.fromJson(json.decode(resp.body.toString()), (item) {
          return item;
        });
        expect(dummies, isNotNull);
        expect(dummies.data.length, 2);
      } catch (err) {
        expect(err, isNull);
      }

      // Update the dummy

      dummy1.content = 'Updated Content 1';
      try {
        var resp = await rest.put(url + '/dummies',
            headers: {'Content-Type': 'application/json'},
            body: json.encode(dummy1.toJson()));
        var dummy = Dummy.fromJson(json.decode(resp.body.toString()));
        expect(dummy, isNotNull);
        expect(dummy.content, 'Updated Content 1');
        expect(dummy.key, _dummy1.key);

        dummy1 = dummy;
      } catch (err) {
        expect(err, isNull);
      }

      // Delete dummy
      try {
        await rest.delete(url + '/dummies/' + dummy1.id);
      } catch (err) {
        expect(err, isNull);
      }

      // Try to get delete dummy
      try {
        var resp = await rest.get(url + '/dummies/' + dummy1.id);
        expect(resp.body, isEmpty);
      } catch (err) {
        expect(err, isNull);
        // expect.isObject(dummy);
      }
    });
  });
}

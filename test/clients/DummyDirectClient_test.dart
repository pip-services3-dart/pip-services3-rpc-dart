import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../Dummy.dart';
import '../DummyController.dart';
import './DummyDirectClient.dart';

void main() {
  group('DummyDirectClient', () {
    Dummy _dummy1;
    Dummy _dummy2;

    DummyDirectClient client;

    setUpAll(() async {
      var ctrl = DummyController();

      client = DummyDirectClient();

      var references = References.fromTuples([
        Descriptor(
            'pip-services-dummies', 'controller', 'default', 'default', '1.0'),
        ctrl
      ]);
      client.setReferences(references);

      await client.open(null);
    });

    tearDownAll(() async {
      await client.close(null);
    });

    setUp(() {
      _dummy1 = Dummy.from(null, 'Key 1', 'Content 1');
      _dummy2 = Dummy.from(null, 'Key 2', 'Content 2');
    });

    test('CRUD Operations', () async {
      var dummy1, dummy2;

      // Create one dummy
      try {
        var dummy = await client.createDummy(null, _dummy1);
        expect(dummy, isNotNull);
        expect(dummy.content, _dummy1.content);
        expect(dummy.key, _dummy1.key);

        dummy1 = dummy;
      } catch (err) {
        expect(err, isNull);
      }

      // Create another dummy
      try {
        var dummy = await client.createDummy(null, _dummy2);
        expect(dummy, isNotNull);
        expect(dummy.content, _dummy2.content);
        expect(dummy.key, _dummy2.key);

        dummy2 = dummy;
      } catch (err) {
        expect(err, isNull);
      }

      // Get all dummies
      try {
        var dummies = await client.getDummies(
            null, FilterParams(), PagingParams(0, 5, false));

        expect(dummies, isNotNull);
        expect(dummies.data.length >= 2, isTrue);
      } catch (err) {
        expect(err, isNull);
      }

      // Update the dummy
      try {
        dummy1.content = 'Updated Content 1';
        var dummy = await client.updateDummy(null, dummy1);
        expect(dummy, isNotNull);
        expect(dummy.content, 'Updated Content 1');
        expect(dummy.key, _dummy1.key);

        dummy1 = dummy;
      } catch (err) {
        expect(err, isNull);
      }

      // Delete dummy
      try {
        await client.deleteDummy(null, dummy1.id);
      } catch (err) {
        expect(err, isNull);
      }

      // Try to get delete dummy
      try {
        var dummy = await client.getDummyById(null, dummy1.id);
        expect(dummy, isNull);
      } catch (err) {
        expect(err, isNull);
      }
    });
  });
}

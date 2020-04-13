import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../Dummy.dart';
import './IDummyClient.dart';

class DummyClientFixture {
  IDummyClient _client;

  DummyClientFixture(IDummyClient client) {
    _client = client;
  }

  testCrudOperations() async {
    var dummy1 = Dummy.from(null, 'Key 1', 'Content 1');
    var dummy2 = Dummy.from(null, 'Key 2', 'Content 2');

    // Create one dummy
    try {
      var dummy = await _client.createDummy(null, dummy1);
      expect(dummy, isNotNull);
      expect(dummy.content, dummy1.content);
      expect(dummy.key, dummy1.key);

      dummy1 = dummy;
    } catch (err) {
      expect(err, isNull);
    }

    // Create another dummy
    try {
      var dummy = await _client.createDummy(null, dummy2);
      expect(dummy, isNotNull);
      expect(dummy.content, dummy2.content);
      expect(dummy.key, dummy2.key);

      dummy2 = dummy;
    } catch (err) {
      expect(err, isNull);
    }

    // Get all dummies
    try {
      var dummies = await _client.getDummies(
          null, FilterParams(), PagingParams(0, 5, false));
      expect(dummies, isNotNull);
      expect(dummies.data.length >= 2, isTrue);
    } catch (err) {
      expect(err, isNull);
    }

    // Update the dummy

    try {
      dummy1.content = 'Updated Content 1';
      var dummy = await _client.updateDummy(null, dummy1);
      expect(dummy, isNotNull);
      expect(dummy.content, 'Updated Content 1');
      expect(dummy.key, dummy1.key);

      dummy1 = dummy;
    } catch (err) {
      expect(err, isNull);
    }

    // Delete dummy
    try {
      await _client.deleteDummy(null, dummy1.id);
    } catch (err) {
      expect(err, isNull);
    }

    // Try to get delete dummy
    try {
      var dummy = await _client.getDummyById(null, dummy1.id);
      expect(dummy, isNull);
    } catch (err) {
      expect(err, isNull);
    }
  }
}

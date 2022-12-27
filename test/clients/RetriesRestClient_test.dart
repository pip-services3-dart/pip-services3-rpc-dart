import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import './DummyRestClient.dart';

var restConfig = ConfigParams.fromTuples([
  'connection.protocol',
  'http',
  'connection.host',
  'localhost',
  'connection.port',
  12345,
  'options.retries',
  2,
  'options.timeout',
  100,
  'options.connect_timeout',
  100
]);

void main() {
  group('RetriesRestClient', () {
    late DummyRestClient client;

    setUp(() async {
      client = DummyRestClient();

      client.configure(restConfig);
      client.setReferences(References());
      await client.open(null);
    });

    test('Retry to call non-existing client', () async {
      try {
        await client.getDummyById(null, '1');
      } catch (err) {
        expect(err, isNotNull);
      }
    });
  });
}

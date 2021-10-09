import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../DummyController.dart';
import '../services/DummyRestService.dart';
import './DummyRestClient.dart';
import './DummyClientFixture.dart';

var restConfig = ConfigParams.fromTuples([
  'connection.protocol',
  'http',
  'connection.host',
  'localhost',
  'connection.port',
  3000
]);

void main() {
  group('DummyRestClient', () {
    late DummyRestService service;
    DummyRestClient client;

    late DummyClientFixture fixture;

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
    });

    tearDown(() async {
      await service.close(null);
    });

    setUp(() async {
      client = DummyRestClient();
      fixture = DummyClientFixture(client);

      client.configure(restConfig);
      client.setReferences(References());
      await client.open(null);
    });

    test('CRUD Operations', () async {
      await fixture.testCrudOperations();
    });
  });
}

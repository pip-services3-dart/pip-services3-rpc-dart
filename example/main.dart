import 'package:pip_services3_commons/pip_services3_commons.dart';
import './Dummy.dart';
import './DummyController.dart';
import './DummyCommandableHttpService.dart';
import './DummyCommandableHttpClient.dart';

void main() async {
  var restConfig = ConfigParams.fromTuples([
    'connection.protocol',
    'http',
    'connection.host',
    'localhost',
    'connection.port',
    3000
  ]);

  DummyCommandableHttpService service;
  DummyCommandableHttpClient client;

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

  client = DummyCommandableHttpClient();

  client.configure(restConfig);
  client.setReferences(References());
  await client.open(null);

  var dummy1 = Dummy.from(null, 'Key 1', 'Content 1');
  var dummy2 = Dummy.from(null, 'Key 2', 'Content 2');

  // Create one dummy
  try {
    var dummy = await client.createDummy(null, dummy1);
    // work with created item

    dummy1 = dummy!;
  } catch (err) {
    // error processing
  }

  // Create another dummy
  try {
    var dummy = await client.createDummy(null, dummy2);
    // work with second created item
    dummy2 = dummy!;
  } catch (err) {
    // error processing
  }

  // Get all dummies
  try {
    var dummies = await client.getDummies(
        null, FilterParams(), PagingParams(0, 5, false));
    // processing recived items
  } catch (err) {
    // error processing
  }

  // Update the dummy
  try {
    dummy1.content = 'Updated Content 1';
    var dummy = await client.updateDummy(null, dummy1);
    // processing with updated item
    dummy1 = dummy!;
  } catch (err) {
    // error processing
  }

  // Delete dummy
  try {
    await client.deleteDummy(null, dummy1.id!);
  } catch (err) {
    // error processing
  }

  // Try to get delete dummy
  try {
    var dummy = await client.getDummyById(null, dummy1.id!);
    // work with deleted item
  } catch (err) {
    // error processing
  }
  // close service and client
  await client.close(null);
  await service.close(null);
}

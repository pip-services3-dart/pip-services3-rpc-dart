import 'dart:async';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';
import './IDummyClient.dart';
import '../IDummyController.dart';
import '../Dummy.dart';

class DummyDirectClient extends DirectClient<IDummyController>
    implements IDummyClient {
  DummyDirectClient() : super() {
    dependencyResolver.put('controller',
        Descriptor('pip-services-dummies', 'controller', '*', '*', '*'));
  }

  @override
  Future<DataPage<Dummy>> getDummies(
      String correlationId, FilterParams filter, PagingParams paging) async {
    var timing = instrument(correlationId, 'dummy.get_page_by_filter');
    var result =
        await controller.getPageByFilter(correlationId, filter, paging);
    timing.endTiming();
    return result;
  }

  Future<Dummy> getDummyById(String correlationId, String dummyId) async {
    var timing = instrument(correlationId, 'dummy.get_one_by_id');
    var result = await controller.getOneById(correlationId, dummyId);

    timing.endTiming();
    return result;
  }

  @override
  Future<Dummy> createDummy(String correlationId, Dummy dummy) async {
    var timing = instrument(correlationId, 'dummy.create');
    var result = await controller.create(correlationId, dummy);
    timing.endTiming();
    return result;
  }

  @override
  Future<Dummy> updateDummy(String correlationId, Dummy dummy) async {
    var timing = instrument(correlationId, 'dummy.update');
    var result = await controller.update(correlationId, dummy);
    timing.endTiming();
    return result;
  }

  @override
  Future<Dummy> deleteDummy(String correlationId, String dummyId) async {
    var timing = instrument(correlationId, 'dummy.delete_by_id');
    var result = await controller.deleteById(correlationId, dummyId);
    timing.endTiming();
    return result;
  }
}

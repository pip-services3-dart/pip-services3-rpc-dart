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
  Future<DataPage<Dummy>?> getDummies(
      String? correlationId, FilterParams? filter, PagingParams? paging) async {
    var timing = instrument(correlationId, 'dummy.get_page_by_filter');
    try {
      return await controller.getPageByFilter(correlationId, filter, paging);
    } catch (ex) {
      timing.endFailure(ex as Exception);
    } finally {
      timing.endTiming();
    }
  }

  @override
  Future<Dummy?> getDummyById(String? correlationId, String dummyId) async {
    var timing = instrument(correlationId, 'dummy.get_one_by_id');
    try {
      return await controller.getOneById(correlationId, dummyId);
    } catch (ex) {
      timing.endFailure(ex as Exception);
    } finally {
      timing.endTiming();
    }
  }

  @override
  Future<Dummy?> createDummy(String? correlationId, Dummy dummy) async {
    var timing = instrument(correlationId, 'dummy.create');
    try {
      return await controller.create(correlationId, dummy);
    } catch (ex) {
      timing.endFailure(ex as Exception);
    } finally {
      timing.endTiming();
    }
  }

  @override
  Future<Dummy?> updateDummy(String? correlationId, Dummy dummy) async {
    var timing = instrument(correlationId, 'dummy.update');
    try {
      return await controller.update(correlationId, dummy);
    } catch (ex) {
      timing.endFailure(ex as Exception);
    } finally {
      timing.endTiming();
    }
  }

  @override
  Future<Dummy?> deleteDummy(String? correlationId, String dummyId) async {
    var timing = instrument(correlationId, 'dummy.delete_by_id');
    try {
      return await controller.deleteById(correlationId, dummyId);
    } catch (ex) {
      timing.endFailure(ex as Exception);
    } finally {
      timing.endTiming();
    }
  }

  @override
  Future<String?> checkCorrelationId(String? correlationId) async {
    var timing = instrument(correlationId, 'dummy.check_correlation_id');
    try {
      return await controller.checkCorrelationId(correlationId);
    } catch (ex) {
      timing.endFailure(ex as Exception);
    } finally {
      timing.endTiming();
    }
  }
}

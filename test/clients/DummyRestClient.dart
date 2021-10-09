import 'dart:async';
import 'dart:convert';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';
import './IDummyClient.dart';
import '../Dummy.dart';

class DummyRestClient extends RestClient implements IDummyClient {
  @override
  Future<DataPage<Dummy>?> getDummies(
      String? correlationId, FilterParams? filter, PagingParams? paging) async {
    var params = <String, String>{};
    addFilterParams(params, filter);
    addPagingParams(params, paging);

    var timing = instrument(correlationId, 'dummy.get_page_by_filter');
    try {
      var result = await call('get', '/dummies', correlationId, params);
      if (result == null) return null;
      return DataPage<Dummy>.fromJson(
          json.decode(result), (item) => Dummy.fromJson(item));
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
      var result =
          await call('get', '/dummies/' + dummyId, correlationId, {}, null);
      if (result == null) return null;
      return Dummy.fromJson(json.decode(result));
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
      var result = await call('post', '/dummies', correlationId, {}, dummy);
      if (result == null) return null;
      return Dummy.fromJson(json.decode(result));
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
      var result = await call('put', '/dummies', correlationId, {}, dummy);
      if (result == null) return null;
      return Dummy.fromJson(json.decode(result));
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
      var result =
          await call('delete', '/dummies/' + dummyId, correlationId, {});
      if (result == null) return null;
      return Dummy.fromJson(json.decode(result));
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
      var result =
          await call('get', '/dummies/check/correlation_id', correlationId, {});
      return result != null ? json.decode(result)['correlation_id'] : null;
    } catch (ex) {
      timing.endFailure(ex as Exception);
    } finally {
      timing.endTiming();
    }
  }
}

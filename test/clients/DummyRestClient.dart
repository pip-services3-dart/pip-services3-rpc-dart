import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../../lib/src/clients/RestClient.dart';
import './IDummyClient.dart';
import '../Dummy.dart';

class DummyRestClient extends RestClient implements IDummyClient {
  @override
  Future<DataPage<Dummy>> getDummies(
      String correlationId, FilterParams filter, PagingParams paging) async {
    var params = {};
    addFilterParams(params, filter);
    addPagingParams(params, paging);

    var result = await call('get', '/dummies', correlationId, params);
    instrument(correlationId, 'dummy.get_page_by_filter');
    if (result == null) return null;
    return DataPage<Dummy>.fromJson(
        json.decode(result), (item) => Dummy.fromJson(item));
  }

  @override
  Future<Dummy> getDummyById(String correlationId, String dummyId) async {
    var result = await call('get', '/dummies/' + dummyId, correlationId, {});
    instrument(correlationId, 'dummy.get_one_by_id');
    if (result == null) return null;
    return Dummy.fromJson(json.decode(result));
  }

  @override
  Future<Dummy> createDummy(String correlationId, Dummy dummy) async {
    var result = await call('post', '/dummies', correlationId, {}, dummy);
    instrument(correlationId, 'dummy.create');
    if (result == null) return null;
    return Dummy.fromJson(json.decode(result));
  }

  @override
  Future<Dummy> updateDummy(String correlationId, Dummy dummy) async {
    var result = await call('put', '/dummies', correlationId, {}, dummy);
    instrument(correlationId, 'dummy.update');
    if (result == null) return null;
    return Dummy.fromJson(json.decode(result));
  }

  @override
  Future<Dummy> deleteDummy(String correlationId, String dummyId) async {
    var result = await call('delete', '/dummies/' + dummyId, correlationId, {});
    instrument(correlationId, 'dummy.delete_by_id');
    if (result == null) return null;
    return Dummy.fromJson(json.decode(result));
  }
}

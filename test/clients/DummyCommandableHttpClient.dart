import 'dart:async';
import 'dart:convert';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../../lib/src/clients/CommandableHttpClient.dart';
import './IDummyClient.dart';
import '../Dummy.dart';

class DummyCommandableHttpClient extends CommandableHttpClient
    implements IDummyClient {
  DummyCommandableHttpClient() : super('dummy');

  @override
  Future<DataPage<Dummy>> getDummies(
      String correlationId, FilterParams filter, PagingParams paging) async {
    var result = await callCommand(
        'get_dummies', correlationId, {'filter': filter, 'paging': paging});
    return DataPage<Dummy>.fromJson(
        json.decode(result), (item) => Dummy.fromJson(item));
  }

  @override
  Future<Dummy> getDummyById(String correlationId, String dummyId) async {
    var result = await callCommand(
        'get_dummy_by_id', correlationId, {'dummy_id': dummyId});
    if (result == null) return null;
    return Dummy.fromJson(json.decode(result));
  }

  @override
  Future<Dummy> createDummy(String correlationId, Dummy dummy) async {
    var result =
        await callCommand('create_dummy', correlationId, {'dummy': dummy});
    if (result == null) return null;
    return Dummy.fromJson(json.decode(result));
  }

  @override
  Future<Dummy> updateDummy(String correlationId, Dummy dummy) async {
    var result =
        await callCommand('update_dummy', correlationId, {'dummy': dummy});
    if (result == null) return null;
    return Dummy.fromJson(json.decode(result));
  }

  @override
  Future<Dummy> deleteDummy(String correlationId, String dummyId) async {
    var result =
        await callCommand('delete_dummy', correlationId, {'dummy_id': dummyId});
    if (result == null) return null;
    return Dummy.fromJson(json.decode(result));
  }
}

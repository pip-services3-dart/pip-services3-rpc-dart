import 'dart:async';
import 'dart:convert';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../Dummy.dart';
import '../IDummyController.dart';

class DummyRestOperations extends RestOperations {
  late IDummyController controller;

  DummyRestOperations() : super.withName('dummy') {
    dependencyResolver.put('controller',
        Descriptor('pip-services-dummies', 'controller', 'default', '*', '*'));
  }

  @override
  void setReferences(IReferences references) {
    super.setReferences(references);
    controller =
        dependencyResolver.getOneRequired<IDummyController>('controller');
  }

  FutureOr<Response> getPageByFilter(Request req) async {
    return await safeInvoke(req, componentName! + '.getPageByFilter', () async {
      var page = await controller.getPageByFilter(
          req.url.queryParameters['correlation_id'],
          FilterParams(req.url.queryParameters),
          PagingParams(req.url.queryParameters));
      return await sendResult(req, null, page);
    }, (ex) async {
      return await sendError(req, ex);
    });
  }

  FutureOr<Response> getOneById(Request req) async {
    return await safeInvoke(req, componentName! + '.getOneById', () async {
      var dummy = await controller.getOneById(
          req.url.queryParameters['correlation_id'], req.params['dummy_id']!);
      return await sendResult(req, null, dummy);
    }, (ex) async {
      return await sendError(req, ex);
    });
  }

  FutureOr<Response> create(Request req) async {
    return await safeInvoke(req, componentName! + '.create', () async {
      var it = await req.readAsString();
      var item = Dummy.fromJson(json.decode(it));
      var dummy = await controller.create(
          req.url.queryParameters['correlation_id'], item);
      return await sendCreatedResult(req, null, dummy);
    }, (ex) async {
      return await sendError(req, ex);
    });
  }

  FutureOr<Response> update(Request req) async {
    return await safeInvoke(req, componentName! + '.update', () async {
      var item = Dummy.fromJson(json.decode(await req.readAsString()));
      var dummy = await controller.update(
          req.url.queryParameters['correlation_id'],
          item); //req.uparams['correlation_id'], item);
      return await sendResult(req, null, dummy);
    }, (ex) async {
      return await sendError(req, ex);
    });
  }

  FutureOr<Response> deleteById(Request req) async {
    return await safeInvoke(req, componentName! + '.deleteById', () async {
      var dummy = await controller.deleteById(
          req.url.queryParameters['correlation_id'],
          req.params['dummy_id']!); //req.params['dummy_id']);
      return await sendCreatedResult(req, null, dummy);
    }, (ex) async {
      return await sendError(req, ex);
    });
  }
}

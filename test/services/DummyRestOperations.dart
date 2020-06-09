import 'package:angel_framework/angel_framework.dart' as angel;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';

import '../Dummy.dart';
import '../IDummyController.dart';

class DummyRestOperations extends RestOperations {
  IDummyController controller;

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

  void getPageByFilter(
      angel.RequestContext req, angel.ResponseContext res) async {
    await safeInvoke(req, res, componentName + '._getPageByFilter', () async {
      var page = await controller.getPageByFilter(
          req.queryParameters['correlation_id'],
          FilterParams(req.queryParameters),
          PagingParams(req.queryParameters));
      sendResult(req, res, null, page);
    }, (ex) async {
      sendError(req, res, ex);
    });
  }

  void getOneById(angel.RequestContext req, angel.ResponseContext res) async {
    await safeInvoke(req, res, componentName + '._getOneById', () async {
      var dummy = await controller.getOneById(
          req.queryParameters['correlation_id'], req.params['dummy_id']);
      sendResult(req, res, null, dummy);
    }, (ex) async {
      sendError(req, res, ex);
    });
  }

  void create(angel.RequestContext req, angel.ResponseContext res) async {
    await safeInvoke(req, res, componentName + '._create', () async {
      await req.parseBody();
      var item = Dummy.fromJson(req.bodyAsMap);
      var dummy = await controller.create(req.params['correlation_id'], item);
      sendCreatedResult(req, res, null, dummy);
    }, (ex) async {
      sendError(req, res, ex);
    });
  }

  void update(angel.RequestContext req, angel.ResponseContext res) async {
    await safeInvoke(req, res, componentName + '._update', () async {
      await req.parseBody();
      var item = Dummy.fromJson(req.bodyAsMap);
      var dummy = await controller.update(req.params['correlation_id'], item);
      sendResult(req, res, null, dummy);
    }, (ex) async {
      sendError(req, res, ex);
    });
  }

  void deleteById(angel.RequestContext req, angel.ResponseContext res) async {
    await safeInvoke(req, res, componentName + '._deleteById', () async {
      var dummy = await controller.deleteById(
          req.queryParameters['correlation_id'], req.params['dummy_id']);
      sendCreatedResult(req, res, null, dummy);
    }, (ex) async {
      sendError(req, res, ex);
    });
  }
}

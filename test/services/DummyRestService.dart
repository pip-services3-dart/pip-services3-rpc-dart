import 'dart:async';
import 'package:angel_framework/angel_framework.dart' as angel;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../DummySchema.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';
import '../IDummyController.dart';
import '../Dummy.dart';
import 'DummyRestOperations.dart';

class DummyRestService extends RestService {
  DummyRestOperations operations = DummyRestOperations();
  IDummyController controller;
  int _numberOfCalls = 0;

  DummyRestService() : super() {
    // dependencyResolver.put('controller',
    //     Descriptor('pip-services-dummies', 'controller', 'default', '*', '*'));
  }

  @override
  void setReferences(IReferences references) {
    super.setReferences(references);
    operations.setReferences(references);
    // controller =
    //     dependencyResolver.getOneRequired<IDummyController>('controller');
  }

  int getNumberOfCalls() {
    return _numberOfCalls;
  }

  Future _incrementNumberOfCalls(
      angel.RequestContext req, angel.ResponseContext res) async {
    _numberOfCalls++;
    return true;
  }

  // void _getPageByFilter(
  //     angel.RequestContext req, angel.ResponseContext res) async {
  //   try {
  //     var page = await controller.getPageByFilter(
  //         req.queryParameters['correlation_id'],
  //         FilterParams(req.queryParameters),
  //         PagingParams(req.queryParameters));
  //     sendResult(req, res, null, page);
  //   } catch (ex) {
  //     sendError(req, res, ex);
  //   }
  // }

  // void _getOneById(angel.RequestContext req, angel.ResponseContext res) async {
  //   try {
  //     var dummy = await controller.getOneById(
  //         req.queryParameters['correlation_id'], req.params['dummy_id']);
  //     sendResult(req, res, null, dummy);
  //   } catch (ex) {
  //     sendError(req, res, ex);
  //   }
  // }

  // void _create(angel.RequestContext req, angel.ResponseContext res) async {
  //   try {
  //     await req.parseBody();
  //     var item = Dummy.fromJson(req.bodyAsMap);
  //     var dummy = await controller.create(req.params['correlation_id'], item);
  //     sendCreatedResult(req, res, null, dummy);
  //   } catch (ex) {
  //     sendError(req, res, ex);
  //   }
  // }

  // void _update(angel.RequestContext req, angel.ResponseContext res) async {
  //   try {
  //     await req.parseBody();
  //     var item = Dummy.fromJson(req.bodyAsMap);
  //     var dummy = await controller.update(req.params['correlation_id'], item);
  //     sendResult(req, res, null, dummy);
  //   } catch (ex) {
  //     sendError(req, res, ex);
  //   }
  // }

  // void _deleteById(angel.RequestContext req, angel.ResponseContext res) async {
  //   try {
  //     var dummy = await controller.deleteById(
  //         req.queryParameters['correlation_id'], req.params['dummy_id']);
  //     sendCreatedResult(req, res, null, dummy);
  //   } catch (ex) {
  //     sendError(req, res, ex);
  //   }
  // }

  @override
  void register() {
    registerInterceptor('/dummies', _incrementNumberOfCalls);

    registerRoute(
        'get',
        '/dummies',
        ObjectSchema(true)
            .withOptionalProperty('skip', TypeCode.String)
            .withOptionalProperty('take', TypeCode.String)
            .withOptionalProperty('total', TypeCode.String)
            .withOptionalProperty('body', FilterParamsSchema()),
        operations.getPageByFilter);

    registerRoute(
        'get',
        '/dummies/:dummy_id',
        ObjectSchema(true).withRequiredProperty('dummy_id', TypeCode.String),
        operations.getOneById);

    registerRoute(
        'post',
        '/dummies',
        ObjectSchema(true).withRequiredProperty('body', DummySchema()),
        operations.create);

    registerRoute(
        'put',
        '/dummies',
        ObjectSchema(true).withRequiredProperty('body', DummySchema()),
        operations.update);

    registerRoute(
        'delete',
        '/dummies/:dummy_id',
        ObjectSchema(true).withRequiredProperty('dummy_id', TypeCode.String),
        operations.deleteById);
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:angel_framework/angel_framework.dart' as angel;
import 'package:angel_framework/http.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../DummySchema.dart';
import '../../lib/src/services/RestService.dart';
import '../IDummyController.dart';
import '../Dummy.dart';

class DummyRestService extends RestService {
  IDummyController controller;
  int _numberOfCalls = 0;

  DummyRestService() : super() {
    dependencyResolver.put('controller',
        Descriptor('pip-services-dummies', 'controller', 'default', '*', '*'));
  }

  @override
  void setReferences(IReferences references) {
    super.setReferences(references);
    controller =
        dependencyResolver.getOneRequired<IDummyController>('controller');
  }

  int getNumberOfCalls() {
    return _numberOfCalls;
  }

  Future _incrementNumberOfCalls(
      angel.RequestContext req, angel.ResponseContext res) async {
    _numberOfCalls++;
    return true;
  }

  void _getPageByFilter(
      angel.RequestContext req, angel.ResponseContext res) async {
    try {
      var page = await controller.getPageByFilter(req.params['correlation_id'],
          FilterParams(req.params), PagingParams(req.params));
      sendResult(req, res, null, page);
    } catch (ex) {
      sendError(req, res, ex);
    }
  }

  void _getOneById(angel.RequestContext req, angel.ResponseContext res) async {
    try {
      var dummy = await controller.getOneById(
          req.params['correlation_id'], req.params['dummy_id']);
      sendResult(req, res, null, dummy);
    } catch (ex) {
      sendError(req, res, ex);
    }
  }

  void _create(angel.RequestContext req, angel.ResponseContext res) {
    try {
      var item = Dummy.fromJson(json.decode(req.body.toString()));
      var dummy = controller.create(req.params['correlation_id'], item);
      sendCreatedResult(req, res, null, dummy);
    } catch (ex) {
      sendError(req, res, ex);
    }
  }

  void _update(angel.RequestContext req, angel.ResponseContext res) async {
    try {
      var item = Dummy.fromJson(json.decode(req.body.toString()));
      var dummy = await controller.update(req.params['correlation_id'], item);
      sendResult(req, res, null, dummy);
    } catch (ex) {
      sendError(req, res, ex);
    }
  }

  void _deleteById(angel.RequestContext req, angel.ResponseContext res) async {
    try {
      var dummy = await controller.deleteById(
          req.params['correlation_id'], req.params['dummy_id']);
      sendCreatedResult(req, res, null, dummy);
    } catch (ex) {
      sendError(req, res, ex);
    }
  }

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
        _getPageByFilter);
  
    registerRoute(
        'get',
        '/dummies/:dummy_id',
        ObjectSchema(true).withRequiredProperty('dummy_id', TypeCode.String),
        _getOneById);

    registerRoute(
        'post',
        '/dummies',
        ObjectSchema(true).withRequiredProperty('body', DummySchema()),
        _create);

    registerRoute(
        'put',
        '/dummies',
        ObjectSchema(true).withRequiredProperty('body', DummySchema()),
        _update);

    registerRoute(
        'delete',
        '/dummies/:dummy_id',
        ObjectSchema(true).withRequiredProperty('dummy_id', TypeCode.String),
        _deleteById);
      
  }
}

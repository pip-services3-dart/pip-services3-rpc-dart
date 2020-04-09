
import 'dart:async';

import 'package:angel_framework/angel_framework.dart' as angel;
import 'package:angel_framework/http.dart';
import  'package:pip_services3_commons/pip_services3_commons.dart';
import '../DummySchema.dart';
import'../../src/services/RestService.dart';
import '../IDummyController.dart';

class DummyRestService extends RestService {
    IDummyController _controller;
    int _numberOfCalls = 0;
	
    DummyRestService(): super() {
        _dependencyResolver.put('controller', Descriptor('pip-services-dummies', 'controller', 'default', '*', '*'));
    }

@override
	void  setReferences(IReferences references) {
		super.setReferences(references);
        _controller = _dependencyResolver.getOneRequired<IDummyController>('controller');
    }
    
    int getNumberOfCalls() {
        return _numberOfCalls;
    }

    Future _incrementNumberOfCalls(angel.RequestContext req, angel.ResponseContext res) async {
        _numberOfCalls++;
        return true;
    }

    void _getPageByFilter(angel.RequestContext req, angel.ResponseContext res) {
        this._controller.getPageByFilter(
            req.params['correlation_id'],
            FilterParams(req.params),
            PagingParams(req.params),
            this.sendResult(req, res)
        );
    }

    void _getOneById(angel.RequestContext req, angel.ResponseContext res) {
        this._controller.getOneById(
            req.params['correlation_id'],
            req.params['dummy_id'],
            this.sendResult(req, res)
        );
    }

    void _create(angel.RequestContext req, angel.ResponseContext res) {
        this._controller.create(
            req.params['correlation_id'],
            req.body,
            this.sendCreatedResult(req, res)
        );
    }

    void _update(angel.RequestContext req, angel.ResponseContext res) {
        this._controller.update(
            req.params['correlation_id'],
            req.body,
            this.sendResult(req, res)
        );
    }

    void _deleteById(angel.RequestContext req, angel.ResponseContext res) {
        this._controller.deleteById(
            req.params['correlation_id'],
            req.params['dummy_id'],
            this.sendDeletedResult(req, res)
        );
    }    
        
    register() {
        registerInterceptor('/dummies', _incrementNumberOfCalls);

        registerRoute(
            'get', '/dummies', 
            ObjectSchema(true)
                .withOptionalProperty('skip', TypeCode.String)
                .withOptionalProperty('take', TypeCode.String)
                .withOptionalProperty('total', TypeCode.String)
                .withOptionalProperty('body', FilterParamsSchema()),
            _getPageByFilter
        );

        registerRoute(
            'get', '/dummies/:dummy_id', 
            ObjectSchema(true)
                .withRequiredProperty('dummy_id', TypeCode.String),
            _getOneById
        );

        registerRoute(
            'post', '/dummies', 
             ObjectSchema(true)
                .withRequiredProperty('body', DummySchema()),
            _create
        );

        registerRoute(
            'put', '/dummies', 
             ObjectSchema(true)
                .withRequiredProperty('body', DummySchema()),
            _update
        );

        registerRoute(
            'delete', '/dummies/:dummy_id', 
             ObjectSchema(true)
                .withRequiredProperty('dummy_id', TypeCode.String),
            _deleteById
        );
    }
}

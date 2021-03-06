import 'dart:async';
import 'package:angel_framework/angel_framework.dart' as angel;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../DummySchema.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';
import '../IDummyController.dart';
import 'DummyRestOperations.dart';

class DummyRestService extends RestService {
  DummyRestOperations operations = DummyRestOperations();
  IDummyController controller;
  int _numberOfCalls = 0;
  String _openApiContent;
  String _openApiFile;

  DummyRestService() : super() {}

  @override
  void setReferences(IReferences references) {
    super.setReferences(references);
    operations.setReferences(references);
  }

  @override
  void configure(ConfigParams config) {
    super.configure(config);

    _openApiContent = config.getAsNullableString('openapi_content');
    _openApiFile = config.getAsNullableString('openapi_file');
  }

  int getNumberOfCalls() {
    return _numberOfCalls;
  }

  Future _incrementNumberOfCalls(
      angel.RequestContext req, angel.ResponseContext res) async {
    _numberOfCalls++;
    return true;
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

    if (_openApiContent != null) registerOpenApiSpec(_openApiContent);
    if (_openApiFile != null) registerOpenApiSpecFromFile(_openApiFile);
  }
}

import 'package:pip_services3_commons/pip_services3_commons.dart';

import './Dummy.dart';
import './IDummyController.dart';
import './DummySchema.dart';

class DummyCommandSet extends CommandSet {
  final IDummyController _controller;

  DummyCommandSet(IDummyController controller)
      : _controller = controller,
        super() {
    addCommand(_makeGetPageByFilterCommand());
    addCommand(_makeGetOneByIdCommand());
    addCommand(_makeCreateCommand());
    addCommand(_makeUpdateCommand());
    addCommand(_makeDeleteByIdCommand());
    addCommand(_makeCheckCorrelationIdCommand());
  }

  ICommand _makeGetPageByFilterCommand() {
    return Command(
        'get_dummies',
        ObjectSchema(true)
            .withOptionalProperty('filter', FilterParamsSchema())
            .withOptionalProperty('paging', PagingParamsSchema()),
        (String? correlationId, Parameters args) async {
      var filter = FilterParams.fromValue(args.get('filter'));
      var paging = PagingParams.fromValue(args.get('paging'));
      return await _controller.getPageByFilter(correlationId, filter, paging);
    });
  }

  ICommand _makeGetOneByIdCommand() {
    return Command('get_dummy_by_id',
        ObjectSchema(true).withRequiredProperty('dummy_id', TypeCode.String),
        (String? correlationId, Parameters args) async {
      var id = args.getAsString('dummy_id');
      return await _controller.getOneById(correlationId, id);
    });
  }

  ICommand _makeCreateCommand() {
    return Command('create_dummy',
        ObjectSchema(true).withRequiredProperty('dummy', DummySchema()),
        (String? correlationId, Parameters args) async {
      var entity = Dummy.fromJson(args.get('dummy'));
      return await _controller.create(correlationId, entity);
    });
  }

  ICommand _makeUpdateCommand() {
    return Command('update_dummy',
        ObjectSchema(true).withRequiredProperty('dummy', DummySchema()),
        (String? correlationId, Parameters args) async {
      var entity = Dummy.fromJson(args.get('dummy'));
      return await _controller.update(correlationId, entity);
    });
  }

  ICommand _makeDeleteByIdCommand() {
    return Command('delete_dummy',
        ObjectSchema(true).withRequiredProperty('dummy_id', TypeCode.String),
        (String? correlationId, Parameters args) async {
      var id = args.getAsString('dummy_id');
      return await _controller.deleteById(correlationId, id);
    });
  }

  ICommand _makeCheckCorrelationIdCommand() {
    return Command('check_correlation_id', ObjectSchema(true),
        (String? correlationId, Parameters args) async {
      var value = await _controller.checkCorrelationId(correlationId);
      return {'correlation_id': value};
    });
  }
}

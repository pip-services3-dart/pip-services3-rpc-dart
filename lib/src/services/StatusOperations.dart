import 'package:angel_framework/angel_framework.dart' as angel;
import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import './RestOperations.dart';

class StatusOperations extends RestOperations {
  final _startTime = DateTime.now();
  IReferences _references2;
  ContextInfo _contextInfo;

  StatusOperations() : super() {
    dependencyResolver.put('context-info',
        Descriptor('pip-services', 'context-info', 'default', '*', '1.0'));
  }

  /// Sets references to dependent components.
  ///
  /// - references 	references to locate the component dependencies.
  @override
  void setReferences(IReferences references) {
    _references2 = references;
    super.setReferences(references);

    _contextInfo =
        dependencyResolver.getOneOptional<ContextInfo>('context-info');
  }

  Function(angel.RequestContext req, angel.ResponseContext res)
      getStatusOperation() {
    return (angel.RequestContext req, angel.ResponseContext res) {
      status(req, res);
    };
  }

  /// Handles status requests
  ///
  /// - req   an HTTP request
  /// - res   an HTTP response

  void status(angel.RequestContext req, angel.ResponseContext res) {
    var id = _contextInfo != null ? _contextInfo.contextId : '';
    var name = _contextInfo != null ? _contextInfo.name : 'Unknown';
    var description = _contextInfo != null ? _contextInfo.description : '';
    var uptime = DateTime.now()
        .subtract(Duration(milliseconds: _startTime.millisecondsSinceEpoch));
    var properties = _contextInfo != null ? _contextInfo.properties : '';

    var components = [];
    if (_references2 != null) {
      for (var locator in _references2.getAllLocators()) {
        components.add(locator.toString());
      }
    }

    var status = {
      'id': id,
      'name': name,
      'description': description,
      'start_time': StringConverter.toString2(_startTime),
      'current_time': StringConverter.toString2(DateTime.now()),
      'uptime': uptime,
      'properties': properties,
      'components': components
    };

    sendResult(req, res, null, status);
  }
}

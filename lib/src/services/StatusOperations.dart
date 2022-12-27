import 'dart:async';

import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:shelf/shelf.dart';

import './RestOperations.dart';

class StatusOperations extends RestOperations {
  final _startTime = DateTime.now().toUtc();
  IReferences? _references2;
  ContextInfo? _contextInfo;

  StatusOperations() : super() {
    dependencyResolver.put('context-info',
        Descriptor('pip-services', 'context-info', 'default', '*', '1.0'));
  }

  /// Sets references to dependent components.
  ///
  /// - [references] 	references to locate the component dependencies.
  @override
  void setReferences(IReferences references) {
    _references2 = references;
    super.setReferences(references);

    _contextInfo =
        dependencyResolver.getOneOptional<ContextInfo>('context-info');
  }

  Function(Request req) getStatusOperation() {
    return (Request req) async {
      return await status(req);
    };
  }

  /// Handles status requests
  ///
  /// - [req]   an HTTP request
  /// - [res]   an HTTP response
  FutureOr<Response> status(Request req) async {
    var id = _contextInfo != null ? _contextInfo!.contextId : '';
    var name = _contextInfo != null ? _contextInfo!.name : 'Unknown';
    var description = _contextInfo != null ? _contextInfo!.description : '';
    var uptime = DateTime.now()
        .toUtc()
        .subtract(Duration(milliseconds: _startTime.millisecondsSinceEpoch));
    var properties = _contextInfo != null ? _contextInfo!.properties : '';

    var components = [];
    if (_references2 != null) {
      for (var locator in _references2!.getAllLocators()) {
        components.add(locator.toString());
      }
    }

    var status = {
      'id': id,
      'name': name,
      'description': description,
      'start_time': StringConverter.toString2(_startTime),
      'current_time': StringConverter.toString2(DateTime.now().toUtc()),
      'uptime': uptime.toIso8601String(),
      'properties': properties,
      'components': components
    };

    return await sendResult(req, null, status);
  }
}

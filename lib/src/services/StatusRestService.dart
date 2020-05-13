import 'package:angel_framework/angel_framework.dart' as angel;
import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import './RestService.dart';

/// Service that returns microservice status information via HTTP/REST protocol.
///
/// The service responds on /status route (can be changed) with a JSON object:
/// {
///     - 'id':            unique container id (usually hostname)
///     - 'name':          container name (from ContextInfo)
///     - 'description':   container description (from ContextInfo)
///     - 'start_time':    time when container was started
///     - 'current_time':  current time in UTC
///     - 'uptime':        duration since container start time in milliseconds
///     - 'properties':    additional container properties (from ContextInfo)
///     - 'components':    descriptors of components registered in the container
/// }
///
/// ### Configuration parameters ###
///
/// - [base_route]:              base route for remote URI
/// - [route]:                   status route (default: 'status')
/// - [dependencies]:
///   - [endpoint]:              override for HTTP Endpoint dependency
///   - [controller]:            override for Controller dependency
/// - [connection(s)]:
///   - [discovery_key]:         (optional) a key to retrieve the connection from [IDiscovery]
///   - [protocol]:              connection protocol: http or https
///   - [host]:                  host name or IP address
///   - [port]:                  port number
///   - [uri]:                   resource URI or connection string with all parameters in it
///
/// ### References ###
///
/// - [\*:logger:\*:\*:1.0]               (optional) [ILogger] components to pass log messages
/// - [\*:counters:\*:\*:1.0]             (optional) [ICounters] components to pass collected measurements
/// - [\*:discovery:\*:\*:1.0]            (optional) [IDiscovery] services to resolve connection
/// - [\*:endpoint:http:\*:1.0]          (optional)  [HttpEndpoint] reference
///
/// See [[RestService]]
/// See [[RestClient]]
///
/// ### Example ###
///
///     var service = StatusService();
///     service.configure(ConfigParams.fromTuples([
///         'connection.protocol', 'http',
///         'connection.host', 'localhost',
///         'connection.port', 8080
///     ]));
///
///     await service.open('123')
///     console.log('The Status service is accessible at http://+:8080/status');
///

class StatusRestService extends RestService {
  final _startTime = DateTime.now().toUtc();
  IReferences _references2;
  ContextInfo _contextInfo;
  String _route = 'status';

  /// Creates a new instance of this service.
  StatusRestService() : super() {
    dependencyResolver.put('context-info',
        Descriptor('pip-services', 'context-info', 'default', '*', '1.0'));
  }

  /// Configures component by passing configuration parameters.
  ///
  /// - [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    super.configure(config);

    _route = config.getAsStringWithDefault('route', _route);
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

  /// Registers all service routes in HTTP endpoint.
  @override
  void register() {
    registerRoute('get', _route, null,
        (angel.RequestContext req, angel.ResponseContext res) {
      _status(req, res);
    });
  }

  /// Handles status requests
  ///
  /// - [req]   an HTTP request
  /// - [res]   an HTTP response
  void _status(angel.RequestContext req, angel.ResponseContext res) {
    var id = _contextInfo != null ? _contextInfo.contextId : '';
    var name = _contextInfo != null ? _contextInfo.name : 'Unknown';
    var description = _contextInfo != null ? _contextInfo.description : '';
    var uptime = DateTime.now().toUtc()
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
      'current_time': StringConverter.toString2(DateTime.now().toUtc()),
      'uptime': uptime.toIso8601String(),
      'properties': properties,
      'components': components
    };

    sendResult(req, res, null, status);
  }
}

import 'dart:convert';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:shelf/shelf.dart';
import './RestService.dart';
import 'CommandableSwaggerDocument.dart';

/// Abstract service that receives remove calls via HTTP/REST protocol
/// to operations automatically generated for commands defined in [ICommandable components](https://pub.dev/documentation/pip_services3_commons/latest/pip_services3_commons/ICommandable-class.html).
/// Each command is exposed as POST operation that receives all parameters in body object.
///
/// Commandable services require only 3 lines of code to implement a robust external
/// HTTP-based remote interface.
///
/// ### Configuration parameters ###
///
/// - [base_route]:              base route for remote URI
/// - [dependencies]:
///   - [endpoint]:              override for HTTP Endpoint dependency
///   - [controller]:            override for Controller dependency
/// - [connection](s):
///   - [discovery_key]:         (optional) a key to retrieve the connection from [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html)
///   - [protocol]:              connection protocol: http or https
///   - [host]:                  host name or IP address
///   - [port]:                  port number
///   - [uri]:                   resource URI or connection string with all parameters in it
///
/// ### References ###
///
/// - [\*:logger:\*:\*:1.0]               (optional) [ILogger](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ILogger-class.html) components to pass log messages
/// - [\*:counters:\*:\*:1.0]             (optional) [ICounters](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ICounters-class.html) components to pass collected measurements
/// - [\*:discovery:\*:\*:1.0]            (optional) [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html) services to resolve connection
/// - [\*:endpoint:http:\*:1.0]          (optional)  [HttpEndpoint] reference
///
/// See [CommandableHttpClient]
/// See [RestService]
///
/// ### Example ###
///
///     class MyCommandableHttpService extends CommandableHttpService {
///        MyCommandableHttpService(): base() {
///           dependencyResolver.put(
///               "controller",
///                Descriptor("mygroup","controller","*","*","1.0")
///           );
///        }
///     }
///
///     var service = MyCommandableHttpService();
///     service.configure(ConfigParams.fromTuples([
///         "connection.protocol", "http",
///         "connection.host", "localhost",
///         "connection.port", 8080
///     ]));
///     service.setReferences(References.fromTuples([
///        new Descriptor("mygroup","controller","default","default","1.0"), controller
///     ]));
///
///      await service.open("123");
///      print("The REST service is running on port 8080");
///

abstract class CommandableHttpService extends RestService {
  CommandSet? _commandSet;
  bool swaggerAuto = true;

  /// Creates a new instance of the service.
  ///
  /// - [baseRoute] a service base route.
  CommandableHttpService(String baseRoute) : super() {
    this.baseRoute = baseRoute;
    dependencyResolver.put('controller', 'none');
  }

  ///  Configures component by passing configuration parameters.
  ///
  ///  - config    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    super.configure(config);
    swaggerAuto = config.getAsBooleanWithDefault('swagger.auto', swaggerAuto);
  }

  /// Registers all service routes in HTTP endpoint.
  @override
  void register() {
    var controller =
        dependencyResolver.getOneRequired<ICommandable>('controller');
    _commandSet = controller.getCommandSet();

    var commands = _commandSet?.getCommands() ?? [];
    for (var index = 0; index < commands.length; index++) {
      var command = commands[index];

      var route = command.getName();
      route = route[0] != '/' ? '/' + route : route;

      registerRoute('post', route, null, (Request req) async {
        var params = {};

        if (req.headers['Content-Type'] != null && req.headers.isNotEmpty) {
          var body = await req.readAsString();
          params = body.isNotEmpty ? json.decode(body) : {};
          req = req.change(body: body);
        }

        var correlationId = getCorrelationId(req);
        var args = Parameters.fromValue(params);
        var timing = instrument(
            correlationId, (baseRoute ?? '') + '.' + command.getName());
        try {
          var result = await command.execute(correlationId, args);
          timing.endTiming();
          return await sendResult(req, result);
        } catch (err) {
          instrumentError(
              correlationId, (baseRoute ?? '') + '.' + command.getName(), err);
          return await sendError(req, ApplicationException().wrap(err));
        }
      });
    }
    if (swaggerAuto) {
      var swaggerConfig = config!.getSection('swagger');

      var doc =
          CommandableSwaggerDocument(baseRoute ?? '', swaggerConfig, commands);
      registerOpenApiSpec_(doc.toString());
    }
  }
}

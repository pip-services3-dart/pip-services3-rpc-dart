import 'dart:async';
import './RestClient.dart';

/// Abstract client that calls commandable HTTP service.
///
/// Commandable services are generated automatically for [ICommandable objects](https://pub.dev/documentation/pip_services3_commons/latest/pip_services3_commons/ICommandable-class.html).
/// Each command is exposed as POST operation that receives all parameters
/// in body object.
///
/// ### Configuration parameters ###
///
/// [base_route]:              base route for remote URI
///
/// - [connection](s):
///   - [discovery_key]:         (optional) a key to retrieve the connection from [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html)
///   - [protocol]:              connection protocol: http or https
///   - [host]:                  host name or IP address
///   - [port]:                  port number
///   - [uri]:                   resource URI or connection string with all parameters in it
/// - [options]:
///   - [retries]:               number of retries (default: 3)
///   - [connect_timeout]:       connection timeout in milliseconds (default: 10 sec)
///   - [timeout]:               invocation timeout in milliseconds (default: 10 sec)
///
/// ### References ###
///
/// - \*:logger:\*:\*:1.0         (optional) [ILogger](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ILogger-class.html) components to pass log messages
/// - \*:counters:\*:\*:1.0         (optional) [ICounters](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ICounters-class.html) components to pass collected measurements
/// - \*:discovery:\*:\*:1.0        (optional) [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html) services to resolve connection
///
/// ### Example ###
///
///     class MyCommandableHttpClient extends CommandableHttpClient implements IMyClient {
///        ...
///
///        Future<MyData> getData(String correlationId, String id) async {
///            var result = await callCommand(
///                "get_data",
///                correlationId,
///                { 'id': id });
///           if (result == null) return null;
///           return MyData.fromJson(json.decode(result));
///         }
///         ...
///     }
///
///     var client = MyCommandableHttpClient();
///     client.configure(ConfigParams.fromTuples([
///         "connection.protocol", "http",
///         "connection.host", "localhost",
///         "connection.port", 8080
///     ]));
///
///     var result = await client.getData("123", "1")
///     ...

class CommandableHttpClient extends RestClient {
  /// Creates a new instance of the client.
  ///
  /// - [baseRoute]     a base route for remote service.
  CommandableHttpClient(String baseRoute) : super() {
    this.baseRoute = baseRoute;
  }

  /// Calls a remote method via HTTP commadable protocol.
  /// The call is made via POST operation and all parameters are sent in body object.
  /// The complete route to remote method is defined as baseRoute + "/" + name.
  ///
  /// - [name]              a name of the command to call.
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [params]            command parameters.
  /// Return          Future that receives result or error.

  Future callCommand(String name, String correlationId, params) async {
    var timing = instrument(correlationId, baseRoute + '.' + name);

    try {
      var response = await call('post', name, correlationId, {}, params ?? {});
      timing.endTiming();
      return response;
    } catch (err) {
      timing.endTiming();
      instrumentError(correlationId, baseRoute + '.' + name, err, true);
    }
  }
}

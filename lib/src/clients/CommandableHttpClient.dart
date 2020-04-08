import 'dart:async';
import './RestClient.dart';

/// Abstract client that calls commandable HTTP service.
///
/// Commandable services are generated automatically for [[https://rawgit.com/pip-services-node/pip-services3-commons-node/master/doc/api/interfaces/commands.icommandable.html ICommandable objects]].
/// Each command is exposed as POST operation that receives all parameters
/// in body object.
///
/// ### Configuration parameters ###
///
/// base_route:              base route for remote URI
///
/// - [connection](s):
///   - [discovery_key]:         (optional) a key to retrieve the connection from [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]]
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
/// - \*:logger:\*:\*:1.0         (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/log.ilogger.html ILogger]] components to pass log messages
/// - \*:counters:\*:\*:1.0         (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/count.icounters.html ICounters]] components to pass collected measurements
/// - \*:discovery:\*:\*:1.0        (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]] services to resolve connection
///
/// ### Example ###
///
///     class MyCommandableHttpClient extends CommandableHttpClient implements IMyClient {
///        ...
///
///        Future<MyData> getData(String correlationId, String id) {
///            return callCommand(
///                "get_data",
///                correlationId,
///                { id: id });
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
  /// - baseRoute     a base route for remote service.

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

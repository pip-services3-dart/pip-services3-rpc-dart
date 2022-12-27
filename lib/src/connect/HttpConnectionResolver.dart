import 'dart:async';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

/// Helper class to retrieve connections for HTTP-based services abd clients.
///
/// In addition to regular functions of ConnectionResolver is able to parse http:// URIs
/// and validate connection parameters before returning them.
///
/// ### Configuration parameters ###
///
/// - [connection]:
///   - [discovery_key]:               (optional) a key to retrieve the connection from [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html)
///   - ...                          other connection parameters
///
/// - [connections]:                   alternative to connection
///   - [connection params 1]:       first connection parameters
///   -  ...
///   - [connection params N]:       Nth connection parameters
///   -  ...
///
/// ### References ###
///
/// - [\*:discovery:\*:\*:1.0]            (optional) [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html) services
///
/// See [ConnectionParams](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ConnectionParams-class.html)
/// See [ConnectionResolver](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ConnectionResolver-class.html)
///
/// ### Example ###
///
///     var config = ConfigParams.fromTuples([
///          'connection.host', '10.1.1.100',
///          'connection.port', 8080
///     ]);
///
///     var connectionResolver = HttpConnectionResolver();
///     connectionResolver.configure(config);
///     connectionResolver.setReferences(references);
///
///     var connection = connectionResolver.resolve('123',
///           // Now use connection...
///

class HttpConnectionResolver implements IReferenceable, IConfigurable {
  /// The base connection resolver.
  final connectionResolver = ConnectionResolver();

  /// The base credential resolver.
  final credentialResolver = CredentialResolver();

  /// Configures component by passing configuration parameters.
  ///
  /// - [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    connectionResolver.configure(config);
    credentialResolver.configure(config);
  }

  /// Sets references to dependent components.
  ///
  /// - [references] 	references to locate the component dependencies.
  @override
  void setReferences(IReferences references) {
    connectionResolver.setReferences(references);
    credentialResolver.setReferences(references);
  }

  void _validateConnection(String? correlationId, ConnectionParams? connection,
      CredentialParams? credential) {
    if (connection == null) {
      throw ConfigException(
          correlationId, 'NO_CONNECTION', 'HTTP connection is not set');
    }

    var uri = connection.getUri();
    if (uri != null) return null;

    var protocol = connection.getProtocolWithDefault('http');
    if ('http' != protocol && 'https' != protocol) {
      throw ConfigException(correlationId, 'WRONG_PROTOCOL',
              'Protocol is not supported by REST connection')
          .withDetails('protocol', protocol);
    }

    var host = connection.getHost();
    if (host == null) {
      throw ConfigException(
          correlationId, 'NO_HOST', 'Connection host is not set');
    }

    var port = connection.getPort();
    if (port == 0) {
      throw ConfigException(
          correlationId, 'NO_PORT', 'Connection port is not set');
    }

    // Check HTTPS credentials
    if (protocol == 'https') {
      // Check for credential
      if (credential == null) {
        throw ConfigException(correlationId, 'NO_CREDENTIAL',
            'SSL certificates are not configured for HTTPS protocol');
      } else {
        // Sometimes when we use https we are on an internal network and do not want to have to deal with security.
        // When we need a https connection and we don't want to pass credentials, flag is 'credential.internal_network',
        // this flag just has to be present and non null for this functionality to work.
        if (credential.getAsNullableString('internal_network') == null) {
          if (credential.getAsNullableString('ssl_key_file') == null) {
            throw ConfigException(correlationId, 'NO_SSL_KEY_FILE',
                'SSL key file is not configured in credentials');
          } else if (credential.getAsNullableString('ssl_crt_file') == null) {
            throw ConfigException(correlationId, 'NO_SSL_CRT_FILE',
                'SSL crt file is not configured in credentials');
          }
        }
      }
    }

    return null;
  }

  ConfigParams _composeConnection(
      List<ConfigParams> connections, CredentialParams? credential) {
    var connection = ConfigParams.mergeConfigs(connections);

    var uri = connection.getAsString('uri');

    if (uri == '') {
      var protocol = connection.getAsStringWithDefault('protocol', 'http');
      var host = connection.getAsString('host');
      var port = connection.getAsInteger('port');

      uri = protocol + '://' + host;
      if (port != 0) {
        uri += ':' + port.toString();
      }
      connection.setAsObject('uri', uri);
    } else {
      var address = Uri.parse(uri);
      var protocol = ('' + address.scheme).replaceAll(':', '');

      connection.setAsObject('protocol', protocol);
      connection.setAsObject('host', address.host);
      connection.setAsObject('port', address.port);
    }

    if (connection.getAsString('protocol') == 'https') {
      if (credential?.getAsNullableString('internal_network') == null) {
        connection = connection.override(credential!);
      }
    }

    return connection;
  }

  /// Resolves a single component connection. If connections are configured to be retrieved
  /// from Discovery service it finds a IDiscovery and resolves the connection there.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// Return 			          Future that receives resolved connection
  /// Throws error.
  Future<ConfigParams?> resolve(String? correlationId) async {
    var connection = await connectionResolver.resolve(correlationId);
    var credential = await credentialResolver.lookup(correlationId);
    _validateConnection(correlationId, connection, credential);

    connection = connection ?? ConnectionParams();
    return _composeConnection([connection], credential);
  }

  /// Resolves all component connection. If connections are configured to be retrieved
  /// from Discovery service it finds a IDiscovery and resolves the connection there.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// Return 			Future that receives resolved connections
  /// Throws error.
  Future<ConfigParams> resolveAll(String? correlationId) async {
    var connections = await connectionResolver.resolveAll(correlationId);
    var credential = await credentialResolver.lookup(correlationId);

    for (var connection in connections) {
      _validateConnection(correlationId, connection, credential);
    }

    return _composeConnection(connections, credential);
  }

  /// Registers the given connection in all referenced discovery services.
  /// This method can be used for dynamic service discovery.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [connection]        a connection to register.
  /// Return          future that receives null is registered connection is succes.
  /// Throws error
  Future register(String? correlationId) async {
    var connection = await connectionResolver.resolve(correlationId);
    var credential = await credentialResolver.lookup(correlationId);
    _validateConnection(correlationId, connection, credential);
    await connectionResolver.register(
        correlationId, connection ?? ConnectionParams());
  }
}

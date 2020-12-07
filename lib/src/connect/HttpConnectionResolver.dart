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

  dynamic _validateConnection(String correlationId, ConnectionParams connection,
      CredentialParams credential) {
    if (connection == null) {
      return ConfigException(
          correlationId, 'NO_CONNECTION', 'HTTP connection is not set');
    }

    var uri = connection.getUri();
    if (uri != null) return null;

    var protocol = connection.getProtocol('http');
    if ('http' != protocol && 'https' != protocol) {
      return ConfigException(correlationId, 'WRONG_PROTOCOL',
              'Protocol is not supported by REST connection')
          .withDetails('protocol', protocol);
    }

    var host = connection.getHost();
    if (host == null) {
      return ConfigException(
          correlationId, 'NO_HOST', 'Connection host is not set');
    }

    var port = connection.getPort();
    if (port == 0) {
      return ConfigException(
          correlationId, 'NO_PORT', 'Connection port is not set');
    }

    // Check HTTPS credentials
    if (protocol == 'https') {
      // Check for credential
      if (credential == null) {
        return ConfigException(correlationId, 'NO_CREDENTIAL',
            'SSL certificates are not configured for HTTPS protocol');
      } else {
        if (credential.getAsNullableString('ssl_key_file') == null) {
          return ConfigException(correlationId, 'NO_SSL_KEY_FILE',
              'SSL key file is not configured in credentials');
        } else if (credential.getAsNullableString('ssl_crt_file') == null) {
          return ConfigException(correlationId, 'NO_SSL_CRT_FILE',
              'SSL crt file is not configured in credentials');
        }
      }
    }

    return null;
  }

  void _updateConnection(
      ConnectionParams connection, CredentialParams credential) {
    if (connection == null) return;

    var uri = connection.getUri();

    if (uri == null || uri == '') {
      var protocol = connection.getProtocol('http');
      var host = connection.getHost();
      var port = connection.getPort();

      uri = protocol + '://' + host;
      if (port != 0) {
        uri += ':' + port.toString();
      }
      connection.setUri(uri);
    } else {
      var address = Uri.parse(uri);
      var protocol = ('' + address.scheme).replaceAll(':', '');

      connection.setProtocol(protocol);
      connection.setHost(address.host);
      connection.setPort(address.port);
    }

    if (connection.getProtocol() == 'https') {
      connection.addSection(
          'credential',
          credential.getAsNullableString('internal_network') == null
              ? credential
              : CredentialParams());
    } else {
      connection.addSection('credential', CredentialParams());
    }
  }

  /// Resolves a single component connection. If connections are configured to be retrieved
  /// from Discovery service it finds a IDiscovery and resolves the connection there.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// Return 			          Future that receives resolved connection
  /// Throws error.
  Future<ConnectionParams> resolve(String correlationId) async {
    var connection = await connectionResolver.resolve(correlationId);
    var credential = await credentialResolver.lookup(correlationId);
    _validateConnection(correlationId, connection, credential);
    _updateConnection(connection, credential);
    return connection;
  }

  /// Resolves all component connection. If connections are configured to be retrieved
  /// from Discovery service it finds a IDiscovery and resolves the connection there.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// Return 			Future that receives resolved connections
  /// Throws error.
  Future<List<ConnectionParams>> resolveAll(String correlationId) async {
    var connections = await connectionResolver.resolveAll(correlationId);
    var credential = await credentialResolver.lookup(correlationId);
    for (var connection in connections) {
      _validateConnection(correlationId, connection, credential);
      _updateConnection(connection, credential);
    }

    return connections;
  }

  /// Registers the given connection in all referenced discovery services.
  /// This method can be used for dynamic service discovery.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [connection]        a connection to register.
  /// Return          future that receives null is registered connection is succes.
  /// Throws error
  Future register(String correlationId) async {
    var connection = await connectionResolver.resolve(correlationId);
    var credential = await credentialResolver.lookup(correlationId);
    _validateConnection(correlationId, connection, credential);
    await connectionResolver.register(correlationId, connection);
  }
}

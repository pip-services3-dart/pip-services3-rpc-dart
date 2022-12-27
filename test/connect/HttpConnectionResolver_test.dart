import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';

void main() {
  group('HttpConnectionResolver', () {
    test('Resolve URI', () async {
      var resolver = HttpConnectionResolver();
      resolver.configure(ConfigParams.fromTuples(
          ['connection.uri', 'http://somewhere.com:777']));

      var connection = await resolver.resolve(null);
      expect('http', connection!.getAsString('protocol'));
      expect('somewhere.com', connection.getAsString('host'));
      expect(777, connection.getAsInteger('port'));
    });

    test('Resolve Parameters', () async {
      var resolver = HttpConnectionResolver();
      resolver.configure(ConfigParams.fromTuples([
        'connection.protocol',
        'http',
        'connection.host',
        'somewhere.com',
        'connection.port',
        777
      ]));

      var connection = await resolver.resolve(null);
      expect('http://somewhere.com:777', connection!.getAsString('uri'));
    });

    test('TestHttpsWithCredentialsConnectionParams', () async {
      var resolver = HttpConnectionResolver();
      resolver.configure(ConfigParams.fromTuples([
        'connection.host',
        'somewhere.com',
        'connection.port',
        123,
        'connection.protocol',
        'https',
        'credential.ssl_key_file',
        'ssl_key_file',
        'credential.ssl_crt_file',
        'ssl_crt_file'
      ]));

      var connection = await resolver.resolve(null);
      expect('https', connection!.getAsString('protocol'));
      expect('somewhere.com', connection.getAsString('host'));
      expect(123, connection.getAsInteger('port'));
      expect('https://somewhere.com:123', connection.getAsString('uri'));
      expect('ssl_key_file', connection.getAsString('ssl_key_file'));
      expect('ssl_crt_file', connection.getAsString('ssl_crt_file'));
    });

    test('TestHttpsWithNoCredentialsConnectionParams', () async {
      var resolver = HttpConnectionResolver();
      resolver.configure(ConfigParams.fromTuples([
        'connection.host',
        'somewhere.com',
        'connection.port',
        123,
        'connection.protocol',
        'https',
        'credential.internal_network',
        'internal_network'
      ]));

      var connection = await resolver.resolve(null);
      expect('https', connection!.getAsString('protocol'));
      expect('somewhere.com', connection.getAsString('host'));
      expect(123, connection.getAsInteger('port'));
      expect('https://somewhere.com:123', connection.getAsString('uri'));
      expect(connection.getAsString('internal_network'), isEmpty);
    });

    test('TestHttpsWithMissingCredentialsConnectionParams', () async {
      // section missing
      var resolver = HttpConnectionResolver();
      resolver.configure(ConfigParams.fromTuples([
        'connection.host',
        'somewhere.com',
        'connection.port',
        123,
        'connection.protocol',
        'https'
      ]));

      try {
        await resolver.resolve(null);
        fail('Should throw an exception');
      } catch (err) {
        err as ApplicationException;
        expect('NO_CREDENTIAL', err.code);
        // expect('NO_CREDENTIAL', err.name);
        expect('SSL certificates are not configured for HTTPS protocol',
            err.message);
        expect('Misconfiguration', err.category);
      }

      // ssl_crt_file missing
      resolver = HttpConnectionResolver();
      resolver.configure(ConfigParams.fromTuples([
        'connection.host',
        'somewhere.com',
        'connection.port',
        123,
        'connection.protocol',
        'https',
        'credential.ssl_key_file',
        'ssl_key_file'
      ]));

      try {
        await resolver.resolve(null);
        fail('Should throw an exception');
      } catch (err) {
        err as ApplicationException;
        expect('NO_SSL_CRT_FILE', err.code);
        // expect('NO_SSL_CRT_FILE', err.name);
        expect('SSL crt file is not configured in credentials', err.message);
        expect('Misconfiguration', err.category);
      }

      // ssl_key_file missing
      resolver = HttpConnectionResolver();
      resolver.configure(ConfigParams.fromTuples([
        'connection.host',
        'somewhere.com',
        'connection.port',
        123,
        'connection.protocol',
        'https',
        'credential.ssl_crt_file',
        'ssl_crt_file'
      ]));

      try {
        await resolver.resolve(null);
        fail('Should throw an exception');
      } catch (err) {
        err as ApplicationException;
        expect('NO_SSL_KEY_FILE', err.code);
        // expect('NO_SSL_KEY_FILE', err.name);
        expect('SSL key file is not configured in credentials', err.message);
        expect('Misconfiguration', err.category);
      }

      // ssl_key_file,  ssl_crt_file present
      resolver = HttpConnectionResolver();
      resolver.configure(ConfigParams.fromTuples([
        'connection.host',
        'somewhere.com',
        'connection.port',
        123,
        'connection.protocol',
        'https',
        'credential.ssl_key_file',
        'ssl_key_file',
        'credential.ssl_crt_file',
        'ssl_crt_file'
      ]));

      var connection = await resolver.resolve(null);
      expect('https', connection!.getAsString('protocol'));
      expect('somewhere.com', connection.getAsString('host'));
      expect(123, connection.getAsInteger('port'));
      expect('https://somewhere.com:123', connection.getAsString('uri'));
      expect('ssl_key_file', connection.getAsString('ssl_key_file'));
      expect('ssl_crt_file', connection.getAsString('ssl_crt_file'));
    });
  });
}

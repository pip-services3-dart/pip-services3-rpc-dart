import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../../lib/src/connect/HttpConnectionResolver.dart';

void main() {
  group('HttpConnectionResolver', () {
    test('Resolve URI', () async {
      var resolver = HttpConnectionResolver();
      resolver.configure(ConfigParams.fromTuples(
          ['connection.uri', 'http://somewhere.com:777']));

      var connection = await resolver.resolve(null);
      expect('http', connection.getProtocol());
      expect('somewhere.com', connection.getHost());
      expect(777, connection.getPort());
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
      expect('http://somewhere.com:777', connection.getUri());
    });
  });
}

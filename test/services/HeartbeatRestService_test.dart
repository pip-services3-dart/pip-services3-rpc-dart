import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';

void main() {
  var restConfig = ConfigParams.fromTuples([
    'connection.protocol',
    'http',
    'connection.host',
    'localhost',
    'connection.port',
    3000
  ]);

  group('HeartbeatRestService', () {
    late HeartbeatRestService service;
    late http.Client rest;
    late String url;

    setUpAll(() async {
      service = HeartbeatRestService();
      service.configure(restConfig);

      await service.open(null);
      url = 'http://localhost:3000';
      rest = http.Client();
    });

    tearDownAll(() async {
      await service.close(null);
    });

    test('Status', () async {
      try {
        var resp = await rest.get(Uri.parse(url + '/heartbeat'));

        print(resp.body.toString());

        expect(resp.body.toString(), isNotNull);
      } catch (err) {
        expect(err, isNull);
      }
    });
  });
}

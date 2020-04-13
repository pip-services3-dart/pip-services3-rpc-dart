import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../../lib/src/services/HeartbeatRestService.dart';

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
    HeartbeatRestService service;
    http.Client rest;
    String url;

    setUpAll(() async {
      service = HeartbeatRestService();
      service.configure(restConfig);

      await service.open(null);
      url = 'http://localhost:3000';
      rest = http.Client();
    });

    tearDownAll(() async {
      await service.close(null);
      //print('HeartbeatRestService Endpoint closed');
    });

   
    test('Status', () async {

      try {
        var resp = await rest.get(url + '/heartbeat');

        print(resp.body.toString());

        expect(resp.body.toString(), isNotNull);
      } catch (err) {
        expect(err, isNull);
      }

    });
  });
}

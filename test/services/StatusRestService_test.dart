import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

import '../../lib/src/services/StatusRestService.dart';

void main() {
  var restConfig = ConfigParams.fromTuples([
    'connection.protocol',
    'http',
    'connection.host',
    'localhost',
    'connection.port',
    3000
  ]);

  group('StatusRestService', () {
    StatusRestService service;
    http.Client rest;
    String url;

    setUpAll(() async {
      service = StatusRestService();
      service.configure(restConfig);

      var contextInfo = ContextInfo();
      contextInfo.name = 'Test';
      contextInfo.description = 'This is a test container';

      var references = References.fromTuples([
        Descriptor('pip-services', 'context-info', 'default', 'default', '1.0'),
        contextInfo,
        Descriptor('pip-services', 'status-service', 'http', 'default', '1.0'),
        service
      ]);
      service.setReferences(references);

      await service.open(null);

      url = 'http://localhost:3000';
      rest = http.Client();
    });

    tearDownAll(() async {
      await service.close(null);
      //print('StatusRestService Endpoint closed');
    });

    test('Status', () async {
      try {
        var resp = await rest.get(url + '/status');

        print(resp.body.toString());

        expect(resp.body.toString(), isNotNull);
      } catch (err) {
        expect(err, isNull);
      }
    });
  });
}

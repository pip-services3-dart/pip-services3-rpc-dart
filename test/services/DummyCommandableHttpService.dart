import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../../lib/src/services/CommandableHttpService.dart';

class DummyCommandableHttpService extends CommandableHttpService {
    DummyCommandableHttpService(): super('dummy') {
        _dependencyResolver.put('controller', new Descriptor('pip-services-dummies', 'controller', 'default', '*', '*'));
    }
}
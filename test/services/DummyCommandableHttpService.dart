import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../../lib/src/services/CommandableHttpService.dart';

class DummyCommandableHttpService extends CommandableHttpService {
    DummyCommandableHttpService(): super('dummy') {
        dependencyResolver.put('controller', Descriptor('pip-services-dummies', 'controller', 'default', '*', '*'));
    }
}
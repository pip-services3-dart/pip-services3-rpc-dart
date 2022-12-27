import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';

class DummyCommandableHttpService extends CommandableHttpService {
    DummyCommandableHttpService(): super('dummy') {
        dependencyResolver.put('controller', Descriptor('pip-services-dummies', 'controller', 'default', '*', '*'));
    }
}
import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../services/HttpEndpoint.dart';
import '../services/HeartbeatRestService.dart';
import '../services/StatusRestService.dart';

/// Creates RPC components by their descriptors.
///
/// See [HttpEndpoint]
/// See [HeartbeatRestService]
/// See [StatusRestService]

class DefaultRpcFactory extends Factory {
  static final descriptor =
      Descriptor('pip-services', 'factory', 'rpc', 'default', '1.0');
  static final HttpEndpointDescriptor =
      Descriptor('pip-services', 'endpoint', 'http', '*', '1.0');
  static final StatusServiceDescriptor =
      Descriptor('pip-services', 'status-service', 'http', '*', '1.0');
  static final HeartbeatServiceDescriptor =
      Descriptor('pip-services', 'heartbeat-service', 'http', '*', '1.0');

  /// Create a new instance of the factory.
  DefaultRpcFactory() : super() {
    registerAsType(DefaultRpcFactory.HttpEndpointDescriptor, HttpEndpoint);
    registerAsType(
        DefaultRpcFactory.HeartbeatServiceDescriptor, HeartbeatRestService);
    registerAsType(
        DefaultRpcFactory.StatusServiceDescriptor, StatusRestService);
  }
}

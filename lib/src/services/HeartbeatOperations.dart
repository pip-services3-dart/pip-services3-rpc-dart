
import 'package:angel_framework/angel_framework.dart' as angel;
import './RestOperations.dart';

class HeartbeatOperations extends RestOperations {
    HeartbeatOperations():super();

     Function (angel.RequestContext req, angel.ResponseContext res) getHeartbeatOperation() {
        return (angel.RequestContext req, angel.ResponseContext res)  {
            heartbeat(req, res);
        };
    }

    void heartbeat(angel.RequestContext req, angel.ResponseContext res) {
        sendResult(req, res, null, DateTime.now());
    }
}
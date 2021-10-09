import 'dart:async';

import 'package:shelf/shelf.dart';
import './RestOperations.dart';

class HeartbeatOperations extends RestOperations {
  HeartbeatOperations() : super();

  Function(Request req) getHeartbeatOperation() {
    return (Request req) async {
      return await heartbeat(req);
    };
  }

  FutureOr<Response> heartbeat(Request req) async {
    return await sendResult(
        req, null, DateTime.now().toUtc().toIso8601String());
  }
}

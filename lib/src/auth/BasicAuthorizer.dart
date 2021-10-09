import 'dart:async';
import 'package:shelf/shelf.dart';

import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../services/HttpResponseSender.dart';

class BasicAuthorizer {
  Future<Response?> anybody(Request req) async {
    return null;
  }

  Future<Response?> signed(Request req, user) async {
    if (user == null) {
      return await HttpResponseSender.sendError(
          req,
          UnauthorizedException(null, 'NOT_SIGNED',
                  'User must be signed in to perform this operation')
              .withStatus(401));
    }
  }
}

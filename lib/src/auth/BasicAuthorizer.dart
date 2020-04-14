import 'dart:async';
import 'package:angel_framework/angel_framework.dart' as angel;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../services/HttpResponseSender.dart';

class BasicAuthorizer {
  Future<bool> anybody(
      angel.RequestContext req, angel.ResponseContext res) async {
    return true;
  }

  Future<bool> signed(
      angel.RequestContext req, angel.ResponseContext res, user) async {
    if (user == null) {
      HttpResponseSender.sendError(
          req,
          res,
          UnauthorizedException(null, 'NOT_SIGNED',
                  'User must be signed in to perform this operation')
              .withStatus(401));
      return false;
    } else {
      return true;
    }
  }
}

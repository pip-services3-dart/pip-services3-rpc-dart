import 'dart:async';
import 'package:angel_framework/angel_framework.dart' as angel;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../services/HttpResponseSender.dart';

class OwnerAuthorizer {
  Future<bool> owner(angel.RequestContext req, angel.ResponseContext res, user,
      {String idParam = 'user_id'}) async {
    if (user == null) {
      HttpResponseSender.sendError(
          req,
          res,
          UnauthorizedException(null, 'NOT_SIGNED',
                  'User must be signed in to perform this operation')
              .withStatus(401));
      return false;
    } else {
      var userId = req.params[idParam] ?? req.queryParameters[idParam];
      if (user.user_id != userId) {
        HttpResponseSender.sendError(
            req,
            res,
            UnauthorizedException(null, 'FORBIDDEN',
                    'Only data owner can perform this operation')
                .withStatus(403));
        return false;
      } else {
        return true;
      }
    }
  }

  Future<bool> ownerOrAdmin(
      angel.RequestContext req, angel.ResponseContext res, user,
      {String idParam = 'user_id'}) async {
    if (user == null) {
      HttpResponseSender.sendError(
          req,
          res,
          UnauthorizedException(null, 'NOT_SIGNED',
                  'User must be signed in to perform this operation')
              .withStatus(401));
      return false;
    } else {
      var userId = req.params[idParam] || req.queryParameters[idParam];
      var roles = user != null ? user.roles : null;
      var admin = roles['admin'] != null;
      if (user.user_id != userId && !admin) {
        HttpResponseSender.sendError(
            req,
            res,
            UnauthorizedException(null, 'FORBIDDEN',
                    'Only data owner can perform this operation')
                .withStatus(403));
        return false;
      } else {
        return true;
      }
    }
  }
}

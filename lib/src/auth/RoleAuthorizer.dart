import 'dart:async';
import 'package:angel_framework/angel_framework.dart' as angel;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../services/HttpResponseSender.dart';

class RoleAuthorizer {
  Future<bool> userInRoles(angel.RequestContext req, angel.ResponseContext res,
      user, List<String> roles) async {
    if (user == null) {
      HttpResponseSender.sendError(
          req,
          res,
          UnauthorizedException(null, 'NOT_SIGNED',
                  'User must be signed in to perform this operation')
              .withStatus(401));
      return false;
    } else {
      var authorized = false;

      for (var role in roles) {
        authorized = authorized ?? user.roles[role] != null;
      }

      if (!authorized) {
        HttpResponseSender.sendError(
            req,
            res,
            UnauthorizedException(
                    null,
                    'NOT_IN_ROLE',
                    'User must be ' +
                        roles.join(' or ') +
                        ' to perform this operation')
                .withDetails('roles', roles)
                .withStatus(403));
        return false;
      } else {
        return true;
      }
    }
  }

  Future<bool> userInRole(angel.RequestContext req, angel.ResponseContext res,
      user, String role) async {
    return userInRoles(req, res, user, [role]);
  }

  Future<bool> admin(
      angel.RequestContext req, angel.ResponseContext res, user) async {
    return userInRole(req, res, user, 'admin');
  }
}

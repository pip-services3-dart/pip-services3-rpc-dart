import 'dart:async';
import 'package:shelf/shelf.dart';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../services/HttpResponseSender.dart';

class RoleAuthorizer {
  Future<Response?> userInRoles(Request req, user, List<String> roles) async {
    if (user == null) {
      return await HttpResponseSender.sendError(
          req,
          UnauthorizedException(null, 'NOT_SIGNED',
                  'User must be signed in to perform this operation')
              .withStatus(401));
    } else {
      var authorized = false;

      for (var role in roles) {
        authorized = authorized || user.roles[role] != null;
      }

      if (!authorized) {
        return await HttpResponseSender.sendError(
            req,
            UnauthorizedException(
                    null,
                    'NOT_IN_ROLE',
                    'User must be ' +
                        roles.join(' or ') +
                        ' to perform this operation')
                .withDetails('roles', roles)
                .withStatus(403));
      }
    }
  }

  Future<Response?> userInRole(Request req, user, String role) async {
    return await userInRoles(req, user, [role]);
  }

  Future<Response?> admin(Request req, user) async {
    return await userInRole(req, user, 'admin');
  }
}

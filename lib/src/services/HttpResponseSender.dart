import 'dart:convert';
import 'package:angel_framework/angel_framework.dart' as angel;
import 'package:pip_services3_commons/pip_services3_commons.dart';

/// Helper class that handles HTTP-based responses.

class HttpResponseSender {
  /// Sends error serialized as ErrorDescription object
  /// and appropriate HTTP status code.
  /// If status code is not defined, it uses 500 status code.
  ///
  /// - req       a HTTP request object.
  /// - res       a HTTP response object.
  /// - error     an error object to be sent.

  static void sendError(
      angel.RequestContext req, angel.ResponseContext res, error) {
    error = error ?? <String, String>{};
    error = ApplicationException.unwrapError(error);

    // var result = _.pick(error, 'code', 'status', 'name', 'details', 'component', 'message', 'stack', 'cause');
    // result = _.defaults(result, { 'code': 'Undefined', 'status': 500, 'message': 'Unknown error' });

    res.statusCode = error.status;
   res.write(json.encode(error));
  }

  /// Creates a callback function that sends result as JSON object.
  /// That callack function call be called directly or passed
  /// as a parameter to business logic components.
  ///
  /// If object is not null it returns 200 status code.
  /// For null results it returns 204 status code.
  /// If error occur it sends ErrorDescription with approproate status code.
  ///
  /// - req       a HTTP request object.
  /// - res       a HTTP response object.

  static void sendResult(
      angel.RequestContext req, angel.ResponseContext res, err, result) {
    if (err != null) {
      HttpResponseSender.sendError(req, res, err);
      return;
    }
    if (result == null) {
      res.statusCode = 204;
      res.close();
    } else {
     res.write(json.encode(result));
     res.close();
    }
  }

  /// Creates a callback function that sends an empty result with 204 status code.
  /// If error occur it sends ErrorDescription with approproate status code.
  ///
  /// - req       a HTTP request object.
  /// - res       a HTTP response object.

  static void sendEmptyResult(
      angel.RequestContext req, angel.ResponseContext res, err) {
    if (err != null) {
      HttpResponseSender.sendError(req, res, err);
      return;
    }
    res.statusCode = 204;
    res.close();
  }

  /// Creates a callback function that sends newly created object as JSON.
  /// That callack function call be called directly or passed
  /// as a parameter to business logic components.
  ///
  /// If object is not null it returns 201 status code.
  /// For null results it returns 204 status code.
  /// If error occur it sends ErrorDescription with approproate status code.
  ///
  /// - req       a HTTP request object.
  /// - res       a HTTP response object.

  static void sendCreatedResult(
      angel.RequestContext req, angel.ResponseContext res, err, result) {
    if (err != null) {
      HttpResponseSender.sendError(req, res, err);
      return;
    }
    if (result == null) {
      res.statusCode = 204;
    } else {
      res.statusCode = 201;
      res.write(json.encode(result));
    }
  }

  /// Creates a callback function that sends deleted object as JSON.
  /// That callack function call be called directly or passed
  /// as a parameter to business logic components.
  ///
  /// If object is not null it returns 200 status code.
  /// For null results it returns 204 status code.
  /// If error occur it sends ErrorDescription with approproate status code.
  ///
  /// - req       a HTTP request object.
  /// - res       a HTTP response object.

  static void sendDeletedResult(
      angel.RequestContext req, angel.ResponseContext res, err, result) {
    if (err != null) {
      HttpResponseSender.sendError(req, res, err);
      return;
    }
    if (result == null) {
      res.statusCode = 204;
    } else {
      res.statusCode = 200;
     res.write(json.encode(result));
    }
  }
}

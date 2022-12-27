import 'dart:async';
import 'dart:convert';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:shelf/shelf.dart';

/// Helper class that handles HTTP-based responses.

class HttpResponseSender {
  /// Sends error serialized as ErrorDescription object
  /// and appropriate HTTP status code.
  /// If status code is not defined, it uses 500 status code.
  ///
  /// - [req]       a HTTP request object.
  /// - [error]     an error object to be sent.
  static FutureOr<Response> sendError(Request req, error) {
    error = error ?? <String, String>{};
    error = ApplicationException.unwrapError(error);

    return Response(error.status, body: json.encode(error));
  }

  /// Creates a function that sends result as JSON object.
  /// That function call be called directly or passed
  /// as a parameter to business logic components.
  ///
  /// If object is not null it returns 200 status code.
  /// For null results it returns 204 status code.
  /// If error occur it sends ErrorDescription with approproate status code.
  ///
  /// - [req]       a HTTP request object.
  /// - [result]       a result object.
  static FutureOr<Response> sendResult(Request req, result) {
    if (result == null) {
      return Response(204);
    } else {
      return Response(200, body: json.encode(result));
    }
  }

  /// Creates a function that sends an empty result with 204 status code.
  /// If error occur it sends ErrorDescription with approproate status code.
  ///
  /// - [req]       a HTTP request object.
  /// - [err]     an error object to be sent.
  static FutureOr<Response> sendEmptyResult(Request req, err) {
    if (err != null) {
      return HttpResponseSender.sendError(req, err);
    }
    return Response(204);
  }

  /// Creates a function that sends newly created object as JSON.
  /// That callack function call be called directly or passed
  /// as a parameter to business logic components.
  ///
  /// If object is not null it returns 201 status code.
  /// For null results it returns 204 status code.
  /// If error occur it sends ErrorDescription with approproate status code.
  ///
  /// - [req]       a HTTP request object.
  /// - [result]       a result object.
  static FutureOr<Response> sendCreatedResult(Request req, result) {
    if (result == null) {
      return Response(204);
    } else {
      return Response(201, body: json.encode(result));
    }
  }

  /// Creates a function that sends deleted object as JSON.
  /// That callack function call be called directly or passed
  /// as a parameter to business logic components.
  ///
  /// If object is not null it returns 200 status code.
  /// For null results it returns 204 status code.
  /// If error occur it sends ErrorDescription with approproate status code.
  ///
  /// - [req]       a HTTP request object.
  /// - [result]       a result object.
  static FutureOr<Response> sendDeletedResult(Request req, result) {
    if (result == null) {
      return Response(204);
    } else {
      return Response(200, body: json.encode(result));
    }
  }
}

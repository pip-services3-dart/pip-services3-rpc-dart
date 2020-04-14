import 'package:angel_framework/angel_framework.dart' as angel;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

import './HttpResponseSender.dart';

abstract class RestOperations implements IConfigurable, IReferenceable {
  var logger = CompositeLogger();
  var counters = CompositeCounters();
  var dependencyResolver = DependencyResolver();

  RestOperations();

  @override
  void configure(ConfigParams config) {
    dependencyResolver.configure(config);
  }

  @override
  void setReferences(IReferences references) {
    logger.setReferences(references);
    counters.setReferences(references);
    dependencyResolver.setReferences(references);
  }

  dynamic getCorrelationId(angel.RequestContext req) {
    return req.params['correlation_id'];
  }

  FilterParams getFilterParams(angel.RequestContext req) {
    var params = Map.from(req.queryParameters);

    params.remove('skip');
    params.remove('take');
    params.remove('total');

    var filter = FilterParams.fromValue(params);
    return filter;
  }

  PagingParams getPagingParams(angel.RequestContext req) {
    var params = <String, dynamic>{};
    params['skip'] = req.queryParameters['skip'] ?? 0;
    params['take'] = req.queryParameters['take'] ?? 100;
    params['total'] = req.queryParameters['total'] ?? false;
    var paging = PagingParams.fromValue(params);
    return paging;
  }

  void sendResult(
      angel.RequestContext req, angel.ResponseContext res, err, result) {
    HttpResponseSender.sendResult(req, res, err, result);
  }

  void sendEmptyResult(
      angel.RequestContext req, angel.ResponseContext res, err) {
    HttpResponseSender.sendEmptyResult(req, res, err);
  }

  void sendCreatedResult(
      angel.RequestContext req, angel.ResponseContext res, err, result) {
    return HttpResponseSender.sendCreatedResult(req, res, err, result);
  }

  void sendDeletedResult(
      angel.RequestContext req, angel.ResponseContext res, err, result) {
    return HttpResponseSender.sendDeletedResult(req, res, err, result);
  }

  void sendError(angel.RequestContext req, angel.ResponseContext res, error) {
    HttpResponseSender.sendError(req, res, error);
  }

  void sendBadRequest(
      angel.RequestContext req, angel.ResponseContext res, String message) {
    var correlationId = getCorrelationId(req);
    var error = BadRequestException(correlationId, 'BAD_REQUEST', message);
    sendError(req, res, error);
  }

  void sendUnauthorized(
      angel.RequestContext req, angel.ResponseContext res, String message) {
    var correlationId = getCorrelationId(req);
    var error = UnauthorizedException(correlationId, 'UNAUTHORIZED', message);
    sendError(req, res, error);
  }

  void sendNotFound(
      angel.RequestContext req, angel.ResponseContext res, String message) {
    var correlationId = getCorrelationId(req);
    var error = NotFoundException(correlationId, 'NOT_FOUND', message);
    sendError(req, res, error);
  }

  void sendConflict(
      angel.RequestContext req, angel.ResponseContext res, String message) {
    var correlationId = getCorrelationId(req);
    var error = ConflictException(correlationId, 'CONFLICT', message);
    sendError(req, res, error);
  }

  void sendSessionExpired(
      angel.RequestContext req, angel.ResponseContext res, String message) {
    var correlationId = getCorrelationId(req);
    var error = UnknownException(correlationId, 'SESSION_EXPIRED', message);
    error.status = 440;
    sendError(req, res, error);
  }

  void sendInternalError(
      angel.RequestContext req, angel.ResponseContext res, String message) {
    var correlationId = getCorrelationId(req);
    var error = UnknownException(correlationId, 'INTERNAL', message);
    sendError(req, res, error);
  }

  void sendServerUnavailable(
      angel.RequestContext req, angel.ResponseContext res, String message) {
    var correlationId = getCorrelationId(req);
    var error = ConflictException(correlationId, 'SERVER_UNAVAILABLE', message);
    error.status = 503;
    sendError(req, res, error);
  }

  Function(angel.RequestContext req, angel.ResponseContext res) invoke(
      String operation) {
    return (angel.RequestContext req, angel.ResponseContext res) {
      //TODO: Wrote code, if thos methods are needed
      throw Exception('RestOperations: Need wrote Invoke method!!!');
      //this. ['operation'](req, res);
    };
  }
}

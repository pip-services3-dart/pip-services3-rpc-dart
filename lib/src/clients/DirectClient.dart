import 'dart:async';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

/// Abstract client that calls controller directly in the same memory space.
///
/// It is used when multiple microservices are deployed in a single container (monolyth)
/// and communication between them can be done by direct calls rather then through
/// the network.
///
/// ### Configuration parameters ###
///
/// - dependencies:
///   - controller:            override controller descriptor
///
/// ### References ###
///
/// - [\*:logger:\*:\*:1.0]         (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/log.ilogger.html ILogger]] components to pass log messages
/// - [\*:counters:\*:\*:1.0]       (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/count.icounters.html ICounters]] components to pass collected measurements
/// - [\*:controller:\*:\*:1.0]     controller to call business methods
///
/// ### Example ###
///
///     class MyDirectClient extends DirectClient<IMyController> implements IMyClient {
///
///         public constructor() {
///           super();
///           this.dependencyResolver.put('controller', new Descriptor(
///               "mygroup", "controller", "*", "*", "*"));
///         }
///         ...
///
///         public getData(String correlationId, id: string,
///           callback: (err: any, result: MyData) => void): void {
///
///           var timing = this.instrument(correlationId, 'myclient.get_data');
///           this.controller.getData(correlationId, id, (err, result) => {
///              timing.endTiming();
///              this.instrumentError(correlationId, 'myclient.get_data', err, result, callback);
///           });
///         }
///         ...
///     }
///
///     var client = new MyDirectClient();
///     client.setReferences(References.fromTuples(
///         new Descriptor("mygroup","controller","default","default","1.0"), controller
///     ));
///
///     client.getData("123", "1", (err, result) => {
///       ...
///     });

abstract class DirectClient<T>
    implements IConfigurable, IReferenceable, IOpenable {
  /// The controller reference.
  T controller;

  /// The open flag.
  bool opened = true;

  /// The logger.
  var logger = CompositeLogger();

  /// The performance counters
  var counters = CompositeCounters();

  /// The dependency resolver to get controller reference.
  var dependencyResolver = DependencyResolver();

  /// Creates a new instance of the client.

  DirectClient() {
    dependencyResolver.put('controller', 'none');
  }

  /// Configures component by passing configuration parameters.
  ///
  /// - [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    dependencyResolver.configure(config);
  }

  /// Sets references to dependent components.
  ///
  /// - [references] 	references to locate the component dependencies.
  @override
  void setReferences(IReferences references) {
    logger.setReferences(references);
    counters.setReferences(references);
    dependencyResolver.setReferences(references);
    controller = dependencyResolver.getOneRequired<T>('controller');
  }

  /// Adds instrumentation to log calls and measure call time.
  /// It returns a Timing object that is used to end the time measurement.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [name]              a method name.
  /// Returns Timing object to end the time measurement.
  Timing instrument(String correlationId, String name) {
    logger.trace(correlationId, 'Calling %s method', [name]);
    counters.incrementOne(name + '.call_count');
    return counters.beginTiming(name + '.call_time');
  }

  /// Adds instrumentation to error handling.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [name]              a method name.
  /// - [err]               an occured error
  /// - [result]            (optional) an execution result
  /// - [reerror]           flag for rethrow exception
  void instrumentError(String correlationId, String name, err,
      [bool reerror = false]) {
    if (err != null) {
      logger.error(correlationId, ApplicationException().wrap(err), 'Failed to call %s method', [name]);
      counters.incrementOne(name + '.call_errors');
      if (reerror != null && reerror == true) {
        throw err;
      }
    }
  }

  /// Checks if the component is opened.
  ///
  /// Returns true if the component has been opened and false otherwise.
  @override
  bool isOpen() {
    return opened;
  }

  /// Opens the component.
  ///
  /// - [correlationId] 	(optional) transaction id to trace execution through call chain.
  /// Returns 			Future that receives error or null no errors occured.
  @override
  Future open(String correlationId) async {
    if (opened) {
      return null;
    }

    if (controller == null) {
      var err = ConnectionException(
          correlationId, 'NOcontroller', 'Controller reference is missing');

      throw err;
    }

    opened = true;

    logger.info(correlationId, 'Opened direct client');
  }

  /// Closes component and frees used resources.
  ///
  /// - [correlationId] 	(optional) transaction id to trace execution through call chain.
  /// Return 			      Future that receives null no errors occured.
  /// Throw error
  @override
  Future close(String correlationId) async {
    if (opened) {
      logger.info(correlationId, 'Closed direct client');
    }

    opened = false;
  }
}

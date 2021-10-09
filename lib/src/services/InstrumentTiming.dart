import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_components/src/trace/TraceTiming.dart';

class InstrumentTiming {
  final String? _correlationId;
  final String _name;
  final String _verb;
  ILogger? _logger;
  ICounters? _counters;
  CounterTiming? _counterTiming;
  TraceTiming? _traceTiming;

  InstrumentTiming(
      String? correlationId,
      String name,
      String? verb,
      ILogger? logger,
      ICounters? counters,
      CounterTiming? counterTiming,
      TraceTiming? traceTiming)
      : _correlationId = correlationId,
        _name = name,
        _verb = verb ?? 'call',
        _logger = logger,
        _counters = counters,
        _counterTiming = counterTiming,
        _traceTiming = traceTiming;

  void _clear() {
    // Clear references to avoid double processing
    _counters = null;
    _logger = null;
    _counterTiming = null;
    _traceTiming = null;
  }

  void endTiming([Exception? err]) {
    if (err == null) {
      endSuccess();
    } else {
      endFailure(err);
    }
  }

  void endSuccess() {
    if (_counterTiming != null) {
      _counterTiming!.endTiming();
    }
    if (_traceTiming != null) {
      _traceTiming!.endTrace();
    }

    _clear();
  }

  void endFailure([Exception? err]) {
    if (_counterTiming != null) {
      _counterTiming!.endTiming();
    }

    if (err != null) {
      if (_logger != null) {
        _logger!
            .error(_correlationId, err, 'Failed to call %s method', [_name]);
      }
      if (_counters != null) {
        _counters!.incrementOne(_name + '.' + _verb + '_errors');
      }
      if (_traceTiming != null) {
        _traceTiming!.endFailure(err);
      }
    } else {
      if (_traceTiming != null) {
        _traceTiming!.endTrace();
      }
    }

    _clear();
  }
}

import 'package:preact_signals/src/future_signal.dart';

/// Extension on future to provide helpful methods for signals
extension SignalFutureUtils on Future {
  /// Convert an existing future to [FutureSignal]
  FutureSignal toSignal({Duration? timeout}) {
    return FutureSignal(
      () => this,
      timeout: timeout,
    );
  }
}

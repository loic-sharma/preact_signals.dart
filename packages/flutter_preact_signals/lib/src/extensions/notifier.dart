import 'package:flutter/foundation.dart';
import 'package:preact_signals/preact_signals.dart';

/// Extension on [ValueNotifier] to provide helpful methods for signals
extension SignalValueNotifierUtils<T> on ValueNotifier<T> {
  MutableSignal<T> toSignal() {
    final s = signal<T>(value);
    addListener(() => s.value = value);
    return s;
  }
}

/// Extension on [ValueListenable] to provide helpful methods for signals
extension SignalValueListenableUtils<T> on ValueListenable<T> {
  ReadonlySignal<T> toSignal() {
    final s = signal<T>(value);
    addListener(() => s.value = value);
    return s;
  }
}

/// Creates a [ReadonlySignal] from a [ValueListenable]
ReadonlySignal<T> signalFromValueListenable<T>(ValueListenable<T> notifier) {
  final s = signal<T>(notifier.value);
  notifier.addListener(() => s.value = notifier.value);
  return s;
}

/// Creates a [MutableSignal] from a [ValueNotifier]
MutableSignal<T> signalFromValueNotifier<T>(ValueNotifier<T> notifier) {
  final s = signal<T>(notifier.value);
  var local = false;
  notifier.addListener(() {
    if (local) {
      local = false;
      return;
    }
    s.value = notifier.value;
  });
  effect(() {
    final val = s.value;
    local = true;
    notifier.value = val;
  });
  return s;
}

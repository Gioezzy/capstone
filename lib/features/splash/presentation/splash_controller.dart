import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model init status. Screen navigates to Home on [ready].
enum SplashStatus { initializing, ready }

class SplashController extends StateNotifier<SplashStatus> {
  SplashController({this.delay = const Duration(seconds: 2)})
      : super(SplashStatus.initializing) {
    _timer = Timer(delay, _markReady);
  }

  final Duration delay;
  Timer? _timer;

  void _markReady() {
    if (mounted) state = SplashStatus.ready;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Overridable in tests to inject a shorter delay.
final splashControllerProvider =
    StateNotifierProvider.autoDispose<SplashController, SplashStatus>(
  (ref) => SplashController(),
);

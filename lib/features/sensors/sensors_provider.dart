import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:sensors_plus/sensors_plus.dart';

final stepCountProvider = StreamProvider.autoDispose<int>((ref) {
  return Pedometer.stepCountStream.map((event) => event.steps);
});

final pedestrianStatusProvider = StreamProvider.autoDispose<String>((ref) {
  return Pedometer.pedestrianStatusStream.map((event) => event.status);
});

final accelerometerProvider = StreamProvider.autoDispose<AccelerometerEvent>((ref) {
  return accelerometerEventStream();
});

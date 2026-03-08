import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'sensors_provider.dart';

class SensorsPage extends ConsumerStatefulWidget {
  const SensorsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SensorsPage> createState() => _SensorsPageState();
}

class _SensorsPageState extends ConsumerState<SensorsPage> {
  bool _hasPermission = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      if (mounted) {
        setState(() {
          _hasPermission = true;
          _permissionDenied = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _permissionDenied = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sensors')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_walk, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Activity Recognition permission is required\nto count your steps.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_permissionDenied) {
                    openAppSettings();
                  } else {
                    _checkPermission();
                  }
                },
                child: Text(_permissionDenied ? 'Open Settings' : 'Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    final stepCountAsync = ref.watch(stepCountProvider);
    final pedestrianStatusAsync = ref.watch(pedestrianStatusProvider);
    final accelerometerAsync = ref.watch(accelerometerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Fitness Sensors')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pedometer Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.directions_walk, size: 48, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text('Step Counter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    stepCountAsync.when(
                      data: (steps) => Text(
                        '$steps',
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text('Error: $err', textAlign: TextAlign.center),
                    ),
                    const Text('Steps', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 16),
                    pedestrianStatusAsync.when(
                      data: (status) => Chip(
                        label: Text('Status: $status'),
                        backgroundColor: status == 'walking' ? Colors.green.shade100 : Colors.grey.shade200,
                      ),
                      loading: () => const Text('Status: Loading...'),
                      error: (err, stack) => const Text('Status: Unknown'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Accelerometer Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.vibration, size: 48, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text('Motion Tracker', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    accelerometerAsync.when(
                      data: (event) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAxisIndicator('X', event.x),
                          _buildAxisIndicator('Y', event.y),
                          _buildAxisIndicator('Z', event.z),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text('Error: $err', textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAxisIndicator(String axis, double value) {
    return Column(
      children: [
        Text(axis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// main.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'pages/map/views/map_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PV Monitoring',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MapView(plantId: 4), // Replace with your plant ID
    );
  }
}

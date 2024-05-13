import 'package:flutter/material.dart';
import 'package:location_sorting/locationservices.dart';

void main() {
  runApp(const LocationApp());
}

class LocationApp extends StatelessWidget {
  const LocationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location App',
      home: LocationServices(),
    );
  }
}

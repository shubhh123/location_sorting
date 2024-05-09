import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

import 'dart:convert'; // For jsonDecode


import 'package:geocoding/geocoding.dart';


import 'dart:math';

class LocationServices extends StatefulWidget {
  const LocationServices({super.key});

  final sourceLattitude = 37.42309125046812;
  final sourceLongitude = -122.0843505;

  static final Map<int, int> storageLocationLatAndLong = {}; 



  final storageDestinationLatitude = 37.42041172519378;
  final storageDestinationLongitude = -122.0978101094947;

  //A StatefulWidget is a widget that maintains state, meaning it can change over time. The state is managed in a corresponding State class.
  @override
  State<LocationServices> createState() => _LocationServicesState(); //_LocationServicesState is the place where the state change happens
}

class _LocationServicesState extends State<LocationServices> {

  @override
  void initState() {
    super.initState();
    // Fetch location when the widget is initialized
    getCurrentLocation();
    findDistanceBetweenSourceToStorage(widget.sourceLattitude, widget.sourceLongitude, widget.storageDestinationLatitude, widget.storageDestinationLongitude);
    loadJsonData();
    checkingGeoCode();
  }

  checkingGeoCode() async{
    debugPrint("Inside checkingGeoCode");
    List<Location> locations = await locationFromAddress("532 S Olive St, Los Angeles, CA 90013");
    //List<Location> locationss = await locationFromAddress("Gronausestraat 710, Enschede");

    debugPrint("Locations from checkingGeoCode ${locations}");

      const query = "1600 Amphiteatre Parkway, Mountain View";

      //var addresses = await Geocoder.local.findAddressesFromQuery(query);
      // var first = addresses.first;
      // debugPrint("${first.featureName} : ${first.coordinates}");
  } 

  getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint("Location access denied. Requesting permission...");
      await Geolocator.requestPermission();
    } else {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      debugPrint("Latitude = ${currentPosition.latitude}");
      debugPrint("Longitude = ${currentPosition.longitude}");
    }
  }

  findDistanceBetweenSourceToStorage(double lat1, double lon1, double lat2, double lon2) {
    const r = 6372.8; // Earth radius in kilometers

    debugPrint("Inside findDistanceBetweenSourceToStorage");
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final lat1Radians = _toRadians(lat1);
    final lat2Radians = _toRadians(lat2);
    
    final a = _haversin(dLat) + cos(lat1Radians) * cos(lat2Radians) * _haversin(dLon);
    final c = 2 * asin(sqrt(a));

    debugPrint("Distance between source to destination: ${r * c} km"); // Providing more context in the debug output
  } 

  double _toRadians(double degrees) => degrees * (pi / 180);

  double _haversin(double radians) => pow(sin(radians / 2), 2) as double;

  Future<void> loadJsonData() async {

      try {
        late List<dynamic> properties;

        final jsonString = await rootBundle.loadString('assets/prop.json');

        final jsonObject = jsonDecode(jsonString);

        final admin = jsonObject['data']['admin'];

        if (admin.containsKey('Properties')) {
            var properties = admin['Properties'];
            
            // Loop through 'Properties' to extract 'Address' and its information
            for (var property in properties) {
              if (property.containsKey('Address')) {
                var address = property['Address']; // Access the 'Address' section

                var lat = address.containsKey('lat') ? address['lat'] : 'Unknown';
                var lng = address.containsKey('lng') ? address['lng'] : 'Unknown';

                //LocationServices.storageLocationLatAndLong.putIfAbsent(lat, lng);

                debugPrint("Address Lat: $lat, Lon: $lng"); // Print 'lat' and 'lng'
                debugPrint("\n");
              }
            }
            debugPrint("Storage Coordinates: ${LocationServices.storageLocationLatAndLong}");

            // debugPrint("Properties: ${properties.toString()}"); // Correct output for debug log.
        }   else {
          debugPrint("No 'Properties' key found in the JSON data.");
        }
      } catch (e) {
        debugPrint("Error loading JSON data: $e");
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: ()  {
            getCurrentLocation(); // This fetches the location when the button is pressed
          },
          child: const Text("Grab location"),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // For jsonDecode
import 'package:geocoding/geocoding.dart';

import 'package:location_sorting/model/address.dart' as customAddress;

import 'package:location_sorting/model/locations.dart';

import 'package:location_sorting/model/properties.dart';

const fetchBackground = "fetchBackground";

//ignore: must_be_immutable
class LocationServices extends StatefulWidget {
  LocationServices({super.key});

  double? sourceLattitude;
  double? sourceLongitude;

  @override
  State<LocationServices> createState() => _LocationServicesState();
}

class _LocationServicesState extends State<LocationServices> {
  List<double> sortedListWrtKm = [];
  Map<double, Properties>
      mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit = {};

  List<Location> storageUnitLocations = [];

  List<Locations> storageUnitLatAndLng = [];

  @override
  void initState() {
    super.initState();
    mainOperation();
  }

  mainOperation() async {
    getCurrentLocationOfTheUser();

    List<Properties> properties = await constructPropertiesObject();

    //debugPrint("Address List length: ${addresses.length}");

    for (Properties property in properties) {
      //debugPrint("Custom address query that will be sent later: ${address.formattedAddressString}");

      customAddress.Address address = property.address;

      try {
        storageUnitLocations = await getStorageUnitLocationsByForwardGeoCoding(
            address.formattedAddressString);
        Locations newLocation = Locations(storageUnitLocations.first.latitude,
            storageUnitLocations.first.longitude, property);
        storageUnitLatAndLng.add(newLocation);
      } catch (e) {
        debugPrint(
            "Some of the address fields were not according to the desired format!");
      }
    }

    for (int i = 0; i < storageUnitLatAndLng.length; i++) {
      findDistanceBetweenUserToStorage(widget.sourceLattitude!,
          widget.sourceLongitude!, storageUnitLatAndLng[i]);
    }

    sortTheMapBasedOnDistance();
  }

  //Future<List<Location>>
  Future<List<Location>> getStorageUnitLocationsByForwardGeoCoding(
      String customAddressQuery) async {
    List<Location> locations = await locationFromAddress(customAddressQuery);

    return locations;
  }

  Future<List<Properties>> constructPropertiesObject() async {
    List<Properties> propertiesList = [];

    try {
      final jsonString = await rootBundle.loadString('assets/prop.json');
      final jsonObject = jsonDecode(jsonString);

      if (jsonObject['data']['admin'].containsKey('Properties')) {
        var propertiesData = jsonObject['data']['admin']['Properties'];
        for (var propertyData in propertiesData) {
          if (propertyData.containsKey('Address')) {
            var addressJson = propertyData['Address'];
            var propertyJson = propertyData;
            propertyJson.remove('Address');

            customAddress.Address address =
                customAddress.Address.fromJson(addressJson);
            Properties properties = Properties.fromJson(propertyJson);
            properties.address = address;

            propertiesList.add(properties);
          }
        }
      } else {
        debugPrint("No 'Properties' key found in the JSON data.");
      }
    } catch (e) {
      debugPrint("Error loading JSON data: $e");
    }

    return propertiesList;
  }

  Future<void> getCurrentLocationOfTheUser() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint("Location access denied. Requesting permission...");
      await Geolocator.requestPermission();
    } else {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      setState(() {
        widget.sourceLattitude = currentPosition.latitude;
        widget.sourceLongitude = currentPosition.longitude;
      });

      debugPrint("Latitude coordinate of the user = ${widget.sourceLattitude}");
      debugPrint(
          "Longitude coordinate of the user = ${widget.sourceLongitude}");
    }
  }

  double findDistanceBetweenUserToStorage(
      double lat1, double lon1, Locations storageUnitLoc) {
    FlutterMapMath flutterMapMath = FlutterMapMath();
    double distance = flutterMapMath.distanceBetween(lat1, lon1,
        storageUnitLoc.latitude, storageUnitLoc.longitude, "kilometers");

    mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit[distance] =
        storageUnitLoc.property;
    return distance;
  }

  void sortTheMapBasedOnDistance() {
    var sortedEntries =
        mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit.entries
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    // Clear the existing map
    mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit.clear();

    // Reconstruct the map from the sorted entries
    for (var entry in sortedEntries) {
      mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit[entry.key] =
          entry.value;
    }

    // Iterate over the sorted map and print or process as needed
    for (var entry
        in mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit
            .entries) {
      double distance = entry.key;
      Properties property = entry.value;

      debugPrint(
          "Distance: $distance km, Property ID: ${property.id}, Address: ${property.address.address}, ${property.address.city}, ${property.address.state}, ${property.address.zip}");
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
          onPressed: getCurrentLocationOfTheUser,
          child: const Text("Grab location"),
        ),
      ),
    );
  }
}

//Operable
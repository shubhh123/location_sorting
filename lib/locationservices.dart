import 'package:flutter/material.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // For jsonDecode
import 'package:geocoding/geocoding.dart';

import 'package:location_sorting/model/address.dart' as customAddress;

import 'package:location_sorting/model/locations.dart';

import 'package:workmanager/workmanager.dart';

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
  Map<double, customAddress.Address>
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

    List<customAddress.Address> addresses = await constructAddressObject();

    //debugPrint("Address List length: ${addresses.length}");

    for (customAddress.Address address in addresses) {
      //debugPrint("Custom address query that will be sent later: ${address.formattedAddressString}");

      try {
        storageUnitLocations = await getStorageUnitLocationsByForwardGeoCoding(
            address.formattedAddressString);
        Locations newLocation = Locations(storageUnitLocations.first.latitude,
            storageUnitLocations.first.longitude, address);
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

  Future<List<customAddress.Address>> constructAddressObject() async {
    List<customAddress.Address> addressList = [];

    try {
      final jsonString = await rootBundle.loadString('assets/prop.json');
      final jsonObject = jsonDecode(jsonString);

      if (jsonObject['data']['admin'].containsKey('Properties')) {
        var properties = jsonObject['data']['admin']['Properties'];
        for (var property in properties) {
          debugPrint("Property file contents: $property");

          if (property.containsKey('Address')) {
            var addressJson =
                property['Address']; // this is expected to be a map

            // Logging the raw data
            //debugPrint("Raw Address Data: $addressJson");

            customAddress.Address newAddress =
                customAddress.Address.fromJson(addressJson);

            addressList.add(newAddress);
          }
        }
      } else {
        debugPrint("No 'Properties' key found in the JSON data.");
      }
    } catch (e) {
      debugPrint("Error loading JSON data: $e");
    }
    return addressList;
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
        storageUnitLoc.storageAddress;
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
      customAddress.Address address = entry.value;

      debugPrint(
          "Distance: $distance km, Address: ${address.formattedAddressString}");
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
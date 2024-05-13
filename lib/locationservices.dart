import 'package:flutter/material.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // For jsonDecode
import 'package:geocoding/geocoding.dart';
import 'dart:math';
import 'package:location_sorting/model/address.dart' as customAddress;

import 'package:location_sorting/model/locations.dart';

//Now compute the distance
//Associate Address Object with Lat and Long

//ignore: must_be_immutable
class LocationServices extends StatefulWidget {
  LocationServices({super.key});

  double? sourceLattitude;
  double? sourceLongitude;

  //static final Map<double, double> storageLocationLatAndLong = {};

  @override
  State<LocationServices> createState() => _LocationServicesState();
}

class _LocationServicesState extends State<LocationServices> {
  List<double> sortedListWrtKm = [];
  Map<double, customAddress.Address>
      mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit = {};

  @override
  void initState() {
    super.initState();
    mainOperation();
  }

  mainOperation() async {
    getCurrentLocationOfTheUser();

    List<Location> storageUnitLocations = [];

    List<Locations> storageUnitLatAndLng = [];

    List<customAddress.Address> addresses = await constructAddressObject();

    //debugPrint("Address List length: ${addresses.length}");

    for (customAddress.Address address in addresses) {
      //debugPrint("Custom address query that will be sent later: ${address.formattedAddressString}");

      try {
        storageUnitLocations = await getStorageUnitLocationsByForwardGeoCoding(
            address.formattedAddressString);

        //Locations(address.latitude, storageUnitLocations.longitude);
        //print("Storage Units lat and lng: ${storageUnitLocations.first.latitude} ${storageUnitLocations.first.longitude}");
        Locations newLocation = Locations(storageUnitLocations.first.latitude,
            storageUnitLocations.first.longitude, address);
        storageUnitLatAndLng.add(newLocation);
      } catch (e) {
        debugPrint(
            "Some of the address fields were not according to the desired format!");
      }
      //debugPrint("${storageUnitLatAndLng.length}");
    }

    for (int i = 0; i < storageUnitLatAndLng.length; i++) {
      //print("${storageUnitLatAndLng[i].latitude} ${storageUnitLatAndLng[i].longitude} mapped to address ${storageUnitLatAndLng[i].storageAddress.address}");

      findDistanceBetweenUserToStorage(widget.sourceLattitude!,
          widget.sourceLongitude!, storageUnitLatAndLng[i]);
    }
    sortedListWrtKm.sort((a, b) => a.compareTo(b));
    // for (double value in sortedListWrtKm) {
    //   debugPrint("Distance from user to storage: $value km");
    // }

    //Iterate Over the Map..
    // Sort the map entries based on distance in ascending order\

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

  //Future<List<Location>>
  Future<List<Location>> getStorageUnitLocationsByForwardGeoCoding(
      String customAddressQuery) async {
    List<Location> locations = await locationFromAddress(customAddressQuery);
    //debugPrint("Lat and Long obtained from the locationFromAddress method: $locations");
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
    // const r = 6372.8; // Earth radius in kilometers

    // //debugPrint("Inside findDistanceBetweenSourceToStorage");
    // final dLat = _toRadians(storageUnitLoc.latitude - lat1);
    // final dLon = _toRadians(storageUnitLoc.longitude - lat1);
    // final lat1Radians = _toRadians(lat1);
    // final lat2Radians = _toRadians(storageUnitLoc.latitude);

    // final a =
    //     _haversin(dLat) + cos(lat1Radians) * cos(lat2Radians) * _haversin(dLon);
    // final c = 2 * asin(sqrt(a));

    // double distance = r * c;

    // //debugPrint("Distance between user to storage unit: ${r * c} km");
    // sortedListWrtKm.add(r * c);

    // mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit[distance] =
    //     storageUnitLoc.storageAddress;

    // debugPrint("\n");
    // return distance;
    FlutterMapMath flutterMapMath = FlutterMapMath();
    double distance = flutterMapMath.distanceBetween(lat1, lon1,
        storageUnitLoc.latitude, storageUnitLoc.longitude, "kilometers");

    mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit[distance] =
        storageUnitLoc.storageAddress;

    return distance;
  }

  double _toRadians(double degrees) => degrees * (pi / 180);
  double _haversin(double radians) => pow(sin(radians / 2), 2) as double;

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
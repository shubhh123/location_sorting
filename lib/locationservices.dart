import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // For jsonDecode
import 'package:geocoding/geocoding.dart';
import 'dart:math';
import 'package:location_sorting/model/address.dart' as customAddress;
import 'package:location_sorting/model/address_with_distance.dart';
import 'package:location_sorting/model/storage_unit.dart';
import 'package:location_sorting/model/locations.dart';


//Now compute the distance
//Associate Address Object with Lat and Long

class LocationServices extends StatefulWidget {
  LocationServices({super.key}); // Removed 'const' because of non-final fields

  double? sourceLattitude; // Nullable values
  double? sourceLongitude;

  static final Map<double, double> storageLocationLatAndLong = {}; // Changed to double

  final double storageDestinationLatitude = 37.42041172519378;
  final double storageDestinationLongitude = -122.0978101094947;

  @override
  State<LocationServices> createState() => _LocationServicesState();
}

class _LocationServicesState extends State<LocationServices> {

  List<double> sortedListWrtKm = [];

  @override
  void initState() {
    super.initState();
    mainOperation(); // Perform some geocoding tasks
    
    //loadJsonData();
  }

  mainOperation() async {
    debugPrint("Inside checkingGeoCode");
    getCurrentLocationOfTheUser(); 
    int distanceFromUserToUnit = 0;
    
    List<Location> storageUnitLocations = [];
    List<AddressWithDistance> addressWithDistances = []; // To store address-distance pairs
  
    List<Locations> storageUnitLatAndLng = [];
    Map<StorageUnit, double> map = {};

    List<customAddress.Address> addresses = await getCustomAddressQuery();
    debugPrint("Address List length: ${addresses.length}");
    for(customAddress.Address address in addresses) {
      //debugPrint("Custom address query that will be sent later: ${address.formattedAddressString}");


      try {
      storageUnitLocations = await getStorageUnitLocationsForwardGeoCoding(address.formattedAddressString);
      //storageUnitLatAndLng

      //Locations(address.latitude, storageUnitLocations.longitude);
        //print("Storage Units lat and lng: ${storageUnitLocations.first.latitude} ${storageUnitLocations.first.longitude}");
        Locations newLocation = Locations(storageUnitLocations.first.latitude, storageUnitLocations.first.longitude, address);
        storageUnitLatAndLng.add(newLocation);
      } catch(e) {
          print("The address was not according to the desired format!");
      }
        //debugPrint("${storageUnitLatAndLng.length}");
    }

    for(int i = 0 ; i<storageUnitLatAndLng.length ; i++) {
      //print("${storageUnitLatAndLng[i].latitude} ${storageUnitLatAndLng[i].longitude} mapped to address ${storageUnitLatAndLng[i].storageAddress.address}");

      double distance = findDistanceBetweenUserToStorage(widget.sourceLattitude as double, widget.sourceLongitude as double,storageUnitLatAndLng[i].latitude, storageUnitLatAndLng[i].longitude);
      //AddressWithDistance newEntry = AddressWithDistance(address, distance);
    }

    sortedListWrtKm.sort((a, b) => a.compareTo(b));

    for (double value in sortedListWrtKm) {
        print("Distance from user to storage in sorted manner: ${value}");
    }

    /*1234 South Main Street, Santa Ana, CA 92707 Santa Ana California United States */
    //List<Location> locations = await locationFromAddress("1234 Main St, Irvine, CA 92614");
    //debugPrint("Storage unit Location from checkingGeoCode: $locations");
    }


    //Future<List<Location>>
    Future<List<Location>> getStorageUnitLocationsForwardGeoCoding(String customAddressQuery) async {
        List<Location> locations = await locationFromAddress(customAddressQuery);
        //debugPrint("Lat and Long obtained from the locationFromAddress method: $locations");
        return locations;
    }

    Future<List<customAddress.Address>> getCustomAddressQuery() async {
  List<customAddress.Address> addressList = [];

  try {
    final jsonString = await rootBundle.loadString('assets/prop.json');
    final jsonObject = jsonDecode(jsonString);

    if (jsonObject['data']['admin'].containsKey('Properties')) {
      var properties = jsonObject['data']['admin']['Properties'];
      for (var property in properties) {
        if (property.containsKey('Address')) {
          var addressJson = property['Address']; // this is expected to be a map

          // Log the raw data to see what you're working with
            //debugPrint("Raw Address Data: $addressJson");

          customAddress.Address newAddress = customAddress.Address.fromJson(addressJson); // Ensure conversion to Address
          addressList.add(newAddress); // Add to list only if correctly converted
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
      debugPrint("Longitude coordinate of the user = ${widget.sourceLongitude}");

      // if (widget.sourceLattitude != null && widget.sourceLongitude != null) {
      //   findDistanceBetweenSourceToStorage(
      //     widget.sourceLattitude!,
      //     widget.sourceLongitude!,
      //     widget.storageDestinationLatitude,
      //     widget.storageDestinationLongitude
      //   );
        
      // } else {
      //   debugPrint("Source coordinates are not yet available.");
      // }
    }
  }

  double findDistanceBetweenUserToStorage(double lat1, double lon1, double lat2, double lon2) {
    const r = 6372.8; // Earth radius in kilometers

    //debugPrint("Inside findDistanceBetweenSourceToStorage");
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lat1);
    final lat1Radians = _toRadians(lat1);
    final lat2Radians = _toRadians(lat2);

    final a = _haversin(dLat) + cos(lat1Radians) * cos(lat2Radians) * _haversin(dLon);
    final c = 2 * asin(sqrt(a));

    double distance = r * c;

    //debugPrint("Distance between user to storage unit: ${r * c} km");
    sortedListWrtKm.add(r * c);

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




//operable
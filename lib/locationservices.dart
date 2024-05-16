import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // For jsonDecode
import 'package:geocoding/geocoding.dart' as geo_coding;
// import 'package:location_sorting/main.dart';

import 'package:location_sorting/model/address.dart' as customAddress;
import 'package:location_sorting/model/locations.dart';
import 'package:location_sorting/model/properties.dart';

import 'package:background_location/background_location.dart';

class LocationServices extends StatefulWidget {
  LocationServices({super.key});

  double? sourceLattitude;
  double? sourceLongitude;

  @override
  State<LocationServices> createState() => _LocationServicesState();
}

class _LocationServicesState extends State<LocationServices> {
  bool _isLoading = true;
  List<double> sortedListWrtKm = [];
  Map<double, Properties>
      mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit = {};
  List<geo_coding.Location> storageUnitLocations = [];
  List<Locations> storageUnitLatAndLng = [];

  bool isLocationServiceInitialized =
      false; // Track if the service is initialized

  Timer? debounceTimer; // Timer to debounce location updates

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  void fetchLocation() async {
    //if (!isLocationServiceInitialized) {
    await BackgroundLocation.setAndroidNotification(
      title: 'Background service is running',
      message: 'Background location in progress',
      icon: '@mipmap/ic_launcher',
    );
    await BackgroundLocation.startLocationService(distanceFilter: 20);

    BackgroundLocation.getLocationUpdates((location) {
      if (location.latitude != null && location.longitude != null) {
        debounceLocationUpdate(
            location.latitude!.toDouble(), location.longitude!.toDouble());
      }
    });

    isLocationServiceInitialized = true; // Mark the service as initialized
    //}
  }

  //This function essentially ensures that mainOperation() is called only after a short delay (1 second) following the last received location update, preventing excessive processing and improving efficiency.
  void debounceLocationUpdate(double latitude, double longitude) {
    if (debounceTimer?.isActive ?? false) {
      //This is to prevent multiple rapid executions of the function
      debounceTimer?.cancel();
    }

    //This sets up a new timer with a duration of 1 second. When this timer expires, it triggers the callback function provided as the second argument.
    debounceTimer = Timer(
      const Duration(seconds: 1),
      () {
        setState(() {
          widget.sourceLattitude = latitude;
          widget.sourceLongitude = longitude;
        });

        print('Inside getLocationUpdates');
        print('''\n
                Latitude:  ${widget.sourceLattitude}
                Longitude: ${widget.sourceLongitude}
              ''');

        mainOperation();
      },
    );
  }

  Future<void> mainOperation() async {
    setState(() {
      _isLoading = true; // Show loading while processing data
    });

    storageUnitLatAndLng.clear();
    mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit.clear();

    List<Properties> properties = await constructPropertiesObject();
    debugPrint("${properties.length}");
    debugPrint("------------------------------");
    debugPrint("\n");
    for (Properties property in properties) {
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

    debugPrint(
        "Map size: ${mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit.length}");

    setState(() {
      _isLoading = false; // Hide loading after data is processed
    });
  }

  Future<List<geo_coding.Location>> getStorageUnitLocationsByForwardGeoCoding(
      String customAddressQuery) async {
    List<geo_coding.Location> locations =
        await geo_coding.locationFromAddress(customAddressQuery);
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

    mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit.clear();

    for (var entry in sortedEntries) {
      mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit[entry.key] =
          entry.value;
    }

    for (var entry
        in mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit
            .entries) {
      double distance = entry.key;
      Properties property = entry.value;

      debugPrint(
          "Distance: $distance km, Property ID: ${property.id}, Address: ${property.address.address}, ${property.address.city}, ${property.address.state}, ${property.address.zip}");
    }
    //mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit.clear();
  }

  // void handleButtonPressed() {
  //   print("Update Location Button Pressed");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Storage Locations"),
        centerTitle: true,
        // actions: [
        //   ElevatedButton(
        //     onPressed: handleButtonPressed,
        //     style: ElevatedButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(horizontal: 10),
        //     ),
        //     child: const Text("Update Location"),
        //   ),
        // ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Sit tight till we load nearest locations...",
                    style: TextStyle(color: Colors.purple),
                  )
                ],
              ),
            )
          : ListView.builder(
              itemCount:
                  mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit
                      .length,
              itemBuilder: (context, index) {
                double distance =
                    mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit
                        .keys
                        .elementAt(index);
                Properties property =
                    mapWithStorageAddressAndTheDistanceBetweenUserAndStorageUnit
                        .values
                        .elementAt(index);

                return ListTile(
                  title: Text("Distance: $distance km"),
                  subtitle: Text(
                    "Property Details: Property ID: ${property.id}, ${property.name}",
                  ),
                  onTap: () {},
                );
              },
            ),
    );
  }
}

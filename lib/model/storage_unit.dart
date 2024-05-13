import 'package:location_sorting/model/address.dart' as customAddress;

class StorageUnit {
  final double userLatitude;
  final double userLongitude;

  final customAddress.Address address;
  final double distance; // Distance from the user to the storage unit

  StorageUnit(
      {required this.userLatitude,
      required this.userLongitude,
      required this.address,
      required this.distance});
}

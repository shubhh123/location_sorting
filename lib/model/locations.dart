import 'package:location_sorting/model/address.dart';

class Locations {
  final double latitude;
  final double longitude;
  final Address storageAddress;
  double? distance; // Nullable distance field

  Locations(this.latitude, this.longitude, this.storageAddress, {this.distance});
  
  double get getLatitude => latitude;
  double get getLongitude => longitude;
}
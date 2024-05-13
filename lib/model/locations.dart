import 'package:location_sorting/model/properties.dart';

class Locations {
  final double latitude;
  final double longitude;
  final Properties property;
  double? distance; // Nullable distance field

  Locations(this.latitude, this.longitude, this.property, {this.distance});

  double get getLatitude => latitude;
  double get getLongitude => longitude;
}

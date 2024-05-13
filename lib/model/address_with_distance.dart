import 'package:location_sorting/model/address.dart';

class AddressWithDistance {
  final Address address;
  final double distance; // Calculated distance in km

  AddressWithDistance(this.address, this.distance); // Constructor
}

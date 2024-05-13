class Address {
  final String id;
  final String address;
  final String address2;
  final String city;
  final String state;
  final String neighborhood;
  final String zip;
  final String country;
  final double lat;
  final double lng;
  final String formatted_address;
  final String district;
  final String region;
  final String created_at;
  final String modified_at;

  Address.empty()
      : id = '',
        address = '',
        address2 = '',
        city = '',
        state = '',
        neighborhood = '',
        zip = '',
        country = '',
        lat = 0.0,
        lng = 0.0,
        formatted_address = '',
        district = '',
        region = '',
        created_at = '',
        modified_at = '';

  Address({
    required this.id,
    required this.address,
    required this.address2, // Can be optional if nullable
    required this.city,
    required this.state,
    required this.neighborhood,
    required this.zip,
    required this.country,
    required this.lat,
    required this.lng,
    required this.formatted_address,
    required this.district,
    required this.region,
    required this.created_at,
    required this.modified_at,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      address: json['address'] ?? '',
      address2: json['address2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      zip: json['zip'] ?? '',
      country: json['country'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      formatted_address: json['formatted_address'] ?? '',
      district: json['district'] ?? '',
      region: json['region'] ?? '',
      created_at: json['created_at'] ?? '',
      modified_at: json['modified_at'] ?? '',
    );
  }

  // Method to return a formatted address string
  String get formattedAddressString {
    return '${address ?? ""}, ${city ?? ""}, ${state ?? ""} ${zip ?? ""}';
  }
}

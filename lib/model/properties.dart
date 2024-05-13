import 'package:location_sorting/model/address.dart';

class Properties {
  List<String> ids = [];
  String id = "";
  String company_id = "";
  String address_id = "";
  String number = "";
  String description = "";
  int status = 0;
  String name = "";
  String legal_name = "";
  String access_id = "";
  String msg = "";
  String? map_published_at; // Nullable String
  String map_published_by = "";
  String gds_id = "";
  String utc_offset = "";
  String unit_count = "";
  String lease_count = "";
  String unitCount = "";
  String occupancy = "";
  bool is_day_closed = false;
  String? localCurrentDate; // Nullable String
  List<dynamic> assets = [];
  List<dynamic> phones = [];
  List<dynamic> emails = [];
  List<dynamic> units = [];
  List<dynamic> hours = [];
  dynamic access; // Nullable dynamic
  Address address = Address.empty();
  List<dynamic> images = [];
  List<dynamic> application = [];
  Map<String, dynamic> applicationConfig = {};
  List<dynamic> checklist = [];
  List<dynamic> connections = [];
  List<dynamic> triggers = [];
  List<dynamic> maintenanceTypes = [];
  List<dynamic> maintenanceExtras = [];
  List<dynamic> insurances = [];
  List<dynamic> products = [];
  List<dynamic> taxRates = [];
  List<dynamic> promotions = [];
  List<dynamic> mailhouses = [];
  Map<String, dynamic> propertyAccountingTemplate = {};
  Map<String, dynamic> leaseTemplates = {
    "storage": {},
    "residential": {},
    "commercial": {}
  };

  Properties.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    company_id = json['company_id'] ?? "";
    address_id = json['address_id'] ?? "";
    number = json['number'] ?? "";
    description = json['description'] ?? "";
    status = json['status'] ?? 0;
    name = json['name'] ?? "";
    legal_name = json['legal_name'] ?? "";
    access_id = json['access_id'] ?? "";
    msg = json['msg'] ?? "";
    map_published_at = json['map_published_at'];
    map_published_by = json['map_published_by'] ?? "";
    gds_id = json['gds_id'] ?? "";
    utc_offset = json['utc_offset'] ?? "";
    unit_count = json['unit_count'] ?? "";
    lease_count = json['lease_count'] ?? "";
    unitCount = json['unitCount'] ?? "";
    occupancy = json['occupancy'] ?? "";
    is_day_closed = json['is_day_closed'] ?? false;
    localCurrentDate = json['localCurrentDate'];
    assets = json['Assets'] ?? [];
    phones = json['Phones'] ?? [];
    emails = json['Emails'] ?? [];
    units = json['Units'] ?? [];
    hours = json['Hours'] ?? [];
    access = json['Access'];
    address = Address.fromJson(json['Address'] ?? {});
    images = json['Images'] ?? [];
    application = json['Application'] ?? [];
    applicationConfig = json['ApplicationConfig'] ?? {};
    checklist = json['Checklist'] ?? [];
    connections = json['Connections'] ?? [];
    triggers = json['Triggers'] ?? [];
    maintenanceTypes = json['MaintenanceTypes'] ?? [];
    maintenanceExtras = json['MaintenanceExtras'] ?? [];
    insurances = json['Insurances'] ?? [];
    products = json['Products'] ?? [];
    taxRates = json['TaxRates'] ?? [];
    promotions = json['Promotions'] ?? [];
    mailhouses = json['Mailhouses'] ?? [];
    propertyAccountingTemplate = json['PropertyAccountingTemplate'] ?? {};
    leaseTemplates = json['LeaseTemplates'] ??
        {"storage": {}, "residential": {}, "commercial": {}};
  }
}

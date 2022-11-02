import 'package:hive/hive.dart';

part 'transport_type.g.dart';

@HiveType(typeId: 2)
class TransportType {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String displayName;
  @HiveField(2)
  double emissionsPerMile; // kg CO2 emissions per mile per capita
  @HiveField(3)
  double commuteDistance = 0; // miles
  @HiveField(4)
  bool isComplete = false;

  TransportType(this.id, this.displayName, this.emissionsPerMile);

  @override
  String toString() {
    return "$id: $displayName, $emissionsPerMile CO2 kg/mi, $commuteDistance mi, isComplete: $isComplete";
  }


  @override
  bool operator ==(Object other) {
    return other.runtimeType == TransportType && id == (other as TransportType).id;
  }

  static final TransportType car = TransportType("car", "Car", 0.44);
  static final TransportType bus = TransportType("bus", "Bus", 0.29);
  static final TransportType heavyRail =
      TransportType("heavy rail", "Heavy Rail", 0.01);
  static final TransportType lightRail =
      TransportType("light rail", "Light Rail", 0.16);
  static final TransportType commuterRail =
      TransportType("commuter rail", "Commuter Rail", 0.15);
  static final TransportType carPool =
      TransportType("car pool", "Carpool", 0.01);
  static final TransportType zeroEmission =
      TransportType("zero emission", "Walking/Biking", 0);
  static final TransportType none = TransportType("none", "No Commute", 0);
  static final List<TransportType> transportTypes = [
    car,
    bus,
    heavyRail,
    lightRail,
    commuterRail,
    carPool,
    zeroEmission,
    none
  ];
}

import 'package:hive_flutter/hive_flutter.dart';

part 'daily_survey.g.dart';

@HiveType(typeId: 1)
class DailySurvey extends HiveObject {
  @HiveField(0)
  Map<String, int> foodTypes;
  @HiveField(1)
  double totalEmissions = 0;
  @HiveField(2)
  double commuteDistance;
  @HiveField(3)
  double emissionsFromAdditionalTravel;

  DailySurvey(this.foodTypes, this.commuteDistance, this.emissionsFromAdditionalTravel);

  @override
  String toString() {
    return foodTypes.toString();
  }
}

DateTime getCurrentDate() {
  var now = DateTime.now();
  return now.subtract(Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
      milliseconds: now.millisecond,
      microseconds: now.microsecond));
}

// get week start date of current date by default or a specific date
// ignore: avoid_init_to_null
DateTime getWeekStartDate({DateTime? specificDate = null}) {
  DateTime date = specificDate ?? DateTime.now();
  return date.subtract(Duration(
    days: date.weekday - 1,
    hours: date.hour,
    minutes: date.minute,
    seconds: date.second,
    milliseconds: date.millisecond,
    microseconds: date.microsecond
  ));
}

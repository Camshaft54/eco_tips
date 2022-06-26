import 'package:carbon_tracker/daily_survey/daily_survey.dart';
import 'package:hive/hive.dart';

part 'tip_selection.g.dart';

@HiveType(typeId: 3)
class TipSelection extends HiveObject {
  @HiveField(0)
  List<String> tips;
  @HiveField(1)
  List<List<int>> points = [
    for (int i = 0; i < 7; i++) [0, 0, 0]
  ];
  @HiveField(2)
  List<bool> dailyCheckCompleted = List.filled(7, false);

  // TODO: Implement and work out how to get the monthly total for points to display in the tips home
  @HiveField(3)
  int totalPoints = 0;

  TipSelection(this.tips);

  @override
  String toString() {
    return "Tips: ${tips.join(", ")} - $points pts";
  }

  static String getCurrentKey() =>
      getCurrentWeekStartDate().millisecondsSinceEpoch.toString();
}

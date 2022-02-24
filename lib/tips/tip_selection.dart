import 'package:hive/hive.dart';

part 'tip_selection.g.dart';

@HiveType(typeId: 3)
class TipSelection extends HiveObject {
  @HiveField(0)
  List<String> tips;
  @HiveField(1)
  int points = 0;

  TipSelection(this.tips);

  @override
  String toString() {
    return "Tips: ${tips.join(", ")} - $points pts";
  }
}
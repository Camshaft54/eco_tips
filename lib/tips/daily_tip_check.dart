import 'package:carbon_tracker/homepage.dart';
import 'package:carbon_tracker/tips/tip_loader.dart';
import 'package:carbon_tracker/tips/tip_selection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DailyTipCheck extends StatefulWidget {
  const DailyTipCheck({Key? key}) : super(key: key);

  @override
  State createState() => _DailyTipCheckState();
}

class _DailyTipCheckState extends State<DailyTipCheck> {
  final List<List<bool>> tipCompletionSelections = [for (int i = 0; i < 3; i++) [false, true]];
  final Box<TipSelection> tipsBox = Hive.box<TipSelection>("tips");

  @override
  Widget build(BuildContext context) {
    var currKey = tipsBox.getWeekKey();
    if (currKey == null) {
      throw StateError("DailyTipCheck not possible without current TipSelection in box!");
    }
    var tipSelection = tipsBox.get(currKey)!;

    return Scaffold(
        appBar: AppBar(title: const Text("Daily Tip Check")),
        body: Column(children: [
          const Text(
              "Have you worked on all the tips you pledged? (Be honest!)\nIf the tip can only be completed once, eg. Recycling old batteries, then select yes for the day you completed the tip and yes for every day after.", style: TextStyle(fontSize: 16)),
          FutureBuilder(
              future: TipLoader.allTipsFuture,
              builder: (context, allTipsSnapshot) {
                if (allTipsSnapshot.hasData) {
                  var allTips = allTipsSnapshot.data as Map<String, Tip>;
                  return Column(children: [
                    for (int i = 0; i < 3; i++)
                      buildTipCheck(
                          allTips, tipSelection, tipCompletionSelections, i)
                  ]);
                } else {
                  return const CircularProgressIndicator();
                }
              }),
          buildSurveyButton("Submit", onPressed: () {
            TipLoader.allTipsFuture.then((allTips) {
              int dayOfWeek = DateTime.now().weekday - 1;
              // For each of the three tips in today's sublist, set the tip's value to its difficulty if completed, otherwise 0
              tipSelection.points[dayOfWeek] = [for (int i = 0; i < 3; i++) (tipCompletionSelections[i][0] && allTips[tipSelection.tips[i]] != null) ? allTips[tipSelection.tips[i]]!.difficulty : 0];
              // Add all of today's points to the total points
              tipSelection.totalPoints += tipSelection.points[dayOfWeek].reduce((a, b) => a + b);
              tipSelection.dailyCheckCompleted[dayOfWeek] = true;
              tipSelection.save();
              Navigator.pop(context);
            });
          })
        ]));
  }

  Widget buildTipCheck(Map<String, Tip> allTips, TipSelection tipSelection,
      List<List<bool>> tipCompletionSelections, index) {
    Tip tip = allTips[index.toString()]!;
    return Column(children: [
      Text("${tip.name} (${tip.difficulty} star${tip.difficulty > 1 ? "s" : ""})"),
      ToggleButtons(
          children: const [Text("Yes"), Text("No")],
          isSelected: tipCompletionSelections[index],
          onPressed: (buttonIndex) {
            setState(() {
              tipCompletionSelections[index][buttonIndex] = true;
              tipCompletionSelections[index][(buttonIndex + 1) % 2] = false;
            });
          }),
    ]);
  }
}

import 'package:carbon_tracker/tips/daily_tip_check.dart';
import 'package:carbon_tracker/tips/tip_loader.dart';
import 'package:carbon_tracker/tips/tip_selection.dart';
import 'package:carbon_tracker/tips/weekly_tip_selector.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'homepage.dart';

class TipsHome extends StatefulWidget {
  const TipsHome({Key? key}) : super(key: key);

  @override
  State<TipsHome> createState() => _TipsHomeState();
}

class _TipsHomeState extends State<TipsHome> {
  @override
  Widget build(BuildContext context) {
    var areTipsSelected =
        Hive.box("tips").containsKey(TipSelection.getCurrentKey());

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("N/A", style: const TextStyle(fontSize: 84)),
          buildHelpButton(
              context: context,
              alertTitle: "Tips",
              description:
                  "Tips will provide various suggestions for how you can reduce your carbon footprint in simple ways.",
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10))
        ],
      ),
      RichText(
        text: TextSpan(
            text: "${DateFormat("MMMM").format(DateTime.now())} point total",
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
            children: const [
              TextSpan(
                  text: "daily average CO₂e/kg",
                  style: TextStyle(fontWeight: FontWeight.normal))
            ]),
      ),
      Expanded(
          child: ListView(children: [
        TipSelectionCard(
            context: context,
            setStateCallback: setState,
            toEdit: !areTipsSelected),
        TipCheckCard(
            completed: areTipsSelected &&
                Hive.box("tips")
                    .get(TipSelection.getCurrentKey())
                    .dailyCheckCompleted[DateTime.now().weekday - 1],
            setStateCallback: setState,
            context: context)
        // TODO: prevent user from completing check more than once
      ]))
    ]);
  }
}

class TipSelectionCard extends Card {
  TipSelectionCard(
      {Key? key,
      required BuildContext context,
      required Function setStateCallback,
      bool toEdit = true})
      : super(
            key: key,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const ListTile(
                leading: Icon(Icons.checklist),
                title: Text("Weekly Tip Selection"),
                subtitle:
                    Text("Select which tips you want to focus on this week"),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                    child: (toEdit) ? const Text("Start") : const Text("View"),
                    onPressed: () async {
                      if (toEdit) {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const WeeklyTipSelector()));
                        setStateCallback.call(() {});
                      } else {
                        viewTipsDialog(context);
                      }
                    })
              ])
            ]));
}

class TipCheckCard extends Card {
  TipCheckCard(
      {Key? key,
      required BuildContext context,
      required setStateCallback,
      bool completed = false})
      : super(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text("Daily Tip Check"),
                  subtitle: Text(
                      "Did you work on your weekly tips today? If so, you can earn up to 3 points!"),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                      child: const Text("Start"),
                      onPressed: (completed)
                          ? null
                          : () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DailyTipCheck()));
                              setStateCallback.call(() {});
                            })
                ])
              ],
            ));
}

viewTipsDialog(BuildContext context) {
  TipLoader.allTipsFuture.then((allTips) {
    var tipSelection = Hive.box("tips").get(TipSelection.getCurrentKey())!.tips;
    showDialog(
        context: context,
        builder: (context) =>
            SimpleDialog(title: const Text("Your Tip Selection"), children: [
              for (String tipId in tipSelection)
                SimpleDialogOption(
                    onPressed: () {}, child: Text(allTips[tipId]!.name))
            ]));
  });
}

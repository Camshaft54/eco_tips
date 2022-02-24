import 'package:carbon_tracker/tips/WeeklyTipSelector.dart';
import 'package:flutter/material.dart';

class TipsHome extends StatefulWidget {
  const TipsHome({Key? key}) : super(key: key);

  @override
  State<TipsHome> createState() => _TipsHomeState();
}

class _TipsHomeState extends State<TipsHome> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text("Welcome to Tips!", style: TextStyle(fontSize: 48)),
      const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
              "Tips will provide various suggestions for how you can reduce your carbon footprint in simple ways.",
              textAlign: TextAlign.center)),
      Expanded(
          child: ListView(children: [
        TipSelectionCard(context: context, toEdit: true),
        TipCheckCard(completed: false)
      ]))
    ]);
  }
}

class TipSelectionCard extends Card {
  TipSelectionCard(
      {Key? key, required BuildContext context, bool toEdit = true})
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
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WeeklyTipSelector()));
                    })
              ])
            ]));
}

class TipCheckCard extends Card {
  TipCheckCard({Key? key, bool completed = false})
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
                      onPressed: (completed) ? null : () {})
                ])
              ],
            ));
}

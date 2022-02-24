import 'package:carbon_tracker/daily_survey/daily_survey.dart';
import 'package:carbon_tracker/tips/tip_selection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class WeeklyTipSelector extends StatefulWidget {
  const WeeklyTipSelector({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WeeklyTipSelectorState();
}

class _WeeklyTipSelectorState extends State<WeeklyTipSelector> {
  var allTips = {
    "Use shower for less time": 1,
    "Drive eco-friendly": 1,
    "Use reusable water bottle instead of a single-use one": 2,
    "Reuse bags from grocery store": 3
  };
  var foundTips = [];
  var selectedTips = [];
  var difficultyFilter = 0; // 0 = no filter, 1 = 1 star, 2 = 2 star, 3 = 3 star
  var currentQuery = "";

  @override
  void initState() {
    foundTips = allTips.keys.toList();
    super.initState();
  }

  void filterTips(String query) {
    setState(() {
      if (query.isEmpty) {
        foundTips = allTips.keys.toList();
      } else {
        foundTips = allTips.keys
            .where((tip) => tip.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      if (difficultyFilter != 0) {
        allTips.forEach((tip, difficulty) {
          if (difficulty != difficultyFilter) {
            foundTips.remove(tip);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(difficultyFilter.toString());
    return Scaffold(
        appBar: AppBar(title: const Text("Select Tips")),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Column(children: [
                Text(
                    "Select ${3 - selectedTips.length} ${(selectedTips.isNotEmpty) ? "more " : ""}tips you would like to work on this week.",
                    style: const TextStyle(fontSize: 16)),
                TextField(
                    onChanged: (query) {
                      currentQuery = query;
                      filterTips(query);
                    },
                    decoration: const InputDecoration(
                        icon: Icon(Icons.search), labelText: "Search")),
                Row(children: [
                  const Text("Filter difficulty:"),
                  _buildStarButton(1),
                  const SizedBox(width: 5),
                  _buildStarButton(2),
                  const SizedBox(width: 5),
                  _buildStarButton(3)
                ])
              ])),
          Expanded(
              child: ListView.builder(
            itemCount: foundTips.length,
            itemBuilder: (context, index) => Card(
                child: ListTile(
                    leading: Checkbox(
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              selectedTips.add(index);
                            } else {
                              selectedTips.remove(index);
                            }
                          });
                        },
                        value: selectedTips.contains(index)),
                    title: Text(foundTips[index]))),
          )),
          ElevatedButton(
              child: const Text("Confirm"),
              onPressed: (selectedTips.length == 3)
                  ? () {
                      Hive.box("tips").put(getCurrentWeekStartDate(), TipSelection([])); // TODO: Create tips.json and put ids for tips here
                      Navigator.pop(context);
                    }
                  : null)
        ]));
  }

  ElevatedButton _buildStarButton(int stars) {
    return ElevatedButton(
      child: Text("★" * stars),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
              (difficultyFilter == stars) ? Colors.blue : Colors.white),
          foregroundColor: MaterialStateProperty.all(
              (difficultyFilter == stars) ? Colors.white : Colors.blue)),
      onPressed: () {
        setState(() {
          if (difficultyFilter == stars) {
            difficultyFilter = 0;
          } else {
            difficultyFilter = stars;
          }
          filterTips(currentQuery);
        });
      },
    );
  }
}

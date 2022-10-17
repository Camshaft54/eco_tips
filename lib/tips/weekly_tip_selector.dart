import 'package:eco_tips/tips/tip_loader.dart';
import 'package:eco_tips/tips/tip_selection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class WeeklyTipSelector extends StatefulWidget {
  const WeeklyTipSelector({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WeeklyTipSelectorState();
}

class _WeeklyTipSelectorState extends State<WeeklyTipSelector> {
  List<Tip> foundTips = [];
  List<String> selectedTips = [];
  var difficultyFilter = 0; // 0 = no filter, 1 = 1 star, 2 = 2 star, 3 = 3 star
  var currentQuery = "";

  @override
  void initState() {
    super.initState();
    TipLoader.allTipsFuture
        .then((allTips) => {foundTips = allTips.values.toList()});
  }

  void filterTips(String query, Map<String, Tip> allTips) {
    setState(() {
      if (query.isEmpty) {
        foundTips = allTips.values.toList();
      } else {
        foundTips = allTips.values
            .where(
                (tip) => tip.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      if (difficultyFilter != 0) {
        allTips.forEach((id, tip) {
          if (tip.difficulty != difficultyFilter) {
            foundTips.remove(tip);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Select Tips")),
        body: FutureBuilder(
            future: TipLoader.allTipsFuture,
            builder: (context, allTipsSnapshot) {
              if (allTipsSnapshot.hasData) {
                var allTips = allTipsSnapshot.data as Map<String, Tip>;
                return Column(children: [
                  Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: Column(children: [
                        Text(
                            "Select ${3 - selectedTips.length} ${(selectedTips.isNotEmpty) ? "more " : ""}tips you would like to work on this week.",
                            style: const TextStyle(fontSize: 16)),
                        TextField(
                            onChanged: (query) {
                              currentQuery = query;
                              filterTips(query, allTips);
                            },
                            decoration: const InputDecoration(
                                icon: Icon(Icons.search), labelText: "Search")),
                        Row(children: [
                          const Text("Filter difficulty:"),
                          _buildStarButton(1, allTips),
                          const SizedBox(width: 5),
                          _buildStarButton(2, allTips),
                          const SizedBox(width: 5),
                          _buildStarButton(3, allTips)
                        ])
                      ])),
                  Expanded(
                      child: ListView.builder(
                          itemCount: foundTips.length,
                          itemBuilder: (context, index) {
                            var id = foundTips[index].id;
                            return Card(
                                child: ListTile(
                                    leading: Checkbox(
                                        onChanged: (selectedTips.length == 3 &&
                                                !selectedTips.contains(id))
                                            ? null
                                            : (checked) {
                                                setState(() {
                                                  if (checked == true) {
                                                    selectedTips.add(id);
                                                  } else {
                                                    selectedTips.remove(id);
                                                  }
                                                });
                                              },
                                        value: selectedTips.contains(id)),
                                    title: Text(foundTips[index].name)));
                          })),
                  ElevatedButton(
                      child: const Text("Confirm"),
                      onPressed: (selectedTips.length == 3)
                          ? () {
                              Box<TipSelection> tipsBox = Hive.box<TipSelection>("tips");
                              tipsBox.put(tipsBox.generateWeekKey(),
                                  TipSelection(selectedTips));
                              Navigator.pop(context);
                            }
                          : null)
                ]);
              } else {
                return const CircularProgressIndicator();
              }
            }));
  }

  ElevatedButton _buildStarButton(int stars, Map<String, Tip> allTips) {
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
          filterTips(currentQuery, allTips);
        });
      },
    );
  }
}

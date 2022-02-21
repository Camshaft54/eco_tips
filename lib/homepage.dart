import 'package:carbon_tracker/settings/settings_page.dart';
import 'package:carbon_tracker/tips_home.dart';
import 'package:carbon_tracker/tracker_home.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageIndex = 0;
  var pageNames = [const Text("Tracker"), const Text("Tips"), const Text("Settings")];

  @override
  Widget build(BuildContext context) {
    var pages = [const TrackerHome(), const TipsHome(), const SettingsPage()];
    return Scaffold(
          appBar: AppBar(title: pageNames[pageIndex]),
          body: pages[pageIndex],
          bottomNavigationBar: BottomAppBar(
              color: Colors.blue,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            pageIndex = 0;
                          });
                        },
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon((pageIndex == 0) ? Icons.person : Icons.person_outlined, color: Colors.white),
                              const Text("Tracker",
                                  style: TextStyle(color: Colors.white)),
                            ])),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            pageIndex = 1;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon((pageIndex == 1) ? Icons.lightbulb : Icons.lightbulb_outline, color: Colors.white),
                            const Text("Tips", style: TextStyle(color: Colors.white))
                          ],
                        )),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            pageIndex = 2;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon((pageIndex == 2) ? Icons.settings : Icons.settings_outlined, color: Colors.white),
                            const Text("Settings", style: TextStyle(color: Colors.white))
                          ],
                        ))
                  ])),
        );
  }
}

IconButton buildHelpButton(
    {required BuildContext context,
    required String alertTitle,
    required String description,
    EdgeInsets padding = const EdgeInsets.all(8.0)}) {
  return IconButton(
      icon: const Icon(Icons.help),
      padding: padding,
      constraints: const BoxConstraints(),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text(alertTitle),
                    content: Text(description),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Close'),
                        child: const Text('Close'),
                      )
                    ]));
      });
}

Widget buildSurveyButton(String label,
    {Color color = Colors.blue,
      VoidCallback? onPressed,
      includePadding = true}) {
  return Padding(
      padding: EdgeInsets.symmetric(horizontal: (includePadding) ? 5.0 : 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            child: Text(label),
            onPressed: onPressed,
            style:
            ButtonStyle(backgroundColor: MaterialStateProperty.all(color))),
      ));
}

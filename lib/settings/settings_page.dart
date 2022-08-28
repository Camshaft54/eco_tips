import 'package:carbon_tracker/settings/transport_page.dart';
import 'package:carbon_tracker/settings/transport_type.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../homepage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    var transportBox = Hive.box<TransportType>('transport');
    var hasCompletedTransportSettings =
        transportBox.length == 1 && transportBox.getAt(0)!.isComplete;

    String transportSettingsText;
    Color transportSettingsColor;
    if (hasCompletedTransportSettings) {
      transportSettingsText = "Edit your transportation settings";
      transportSettingsColor = Colors.blue;
    } else {
      transportSettingsText = "Complete your transportation settings";
      transportSettingsColor = Colors.red;
    }

    return Center(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 5.0),
          child: Column(children: [
            buildSurveyButton(transportSettingsText,
                color: transportSettingsColor,
                includePadding: false, onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TransportPage()),
              );
              setState(() {});
            })
          ])),
    );
  }
}

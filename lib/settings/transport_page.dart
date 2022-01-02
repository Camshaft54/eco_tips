import 'package:carbon_tracker/settings/settings_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../homepage.dart';

class TransportPage extends StatefulWidget {
  const TransportPage({Key? key}) : super(key: key);

  @override
  State<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Carbon Tracker Settings",
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Transport Settings'),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              ),
            ),
          ),
          body: const Center(
              child: Padding(
                  child: TransportForm(), padding: EdgeInsets.all(32.0))),
        ));
  }
}

class TransportForm extends StatefulWidget {
  const TransportForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TransportFormState();
}

class TransportType {
  final String id;
  final String displayName;
  final double emissionsPerMile; // kg CO2 emissions per mile per capita

  const TransportType(this.id, this.displayName, this.emissionsPerMile);

  static const TransportType car = TransportType("car", "Car", 0.44);
  static const TransportType bus = TransportType("bus", "Bus", 0.29);
  static const TransportType heavyRail = TransportType("heavy rail", "Heavy Rail", 0.01);
  static const TransportType lightRail = TransportType("light rail", "Light Rail", 0.16);
  static const TransportType commuterRail =
      TransportType("commuter rail", "Commuter Rail", 0.15);
  static const TransportType carPool = TransportType("car pool", "Car Pool", 0.01);
  static const TransportType zeroEmission = TransportType("zero emission", "Walking/Biking", 0);
  static const TransportType none = TransportType("none", "No Commute", 0);
  static const List<TransportType> transportTypes = [
    car,
    bus,
    heavyRail,
    lightRail,
    commuterRail,
    carPool,
    zeroEmission,
    none
  ];
}

class _TransportFormState extends State<TransportForm> {
  final _formKey = GlobalKey<FormState>();
  var currTransport = TransportType.none;

  List<Widget> buildTransportTypeRadios() {
    var list = <Widget>[];
    for (TransportType type in TransportType.transportTypes) {
      list.add(RadioListTile<TransportType>(
          title: Text(type.displayName, style: const TextStyle(fontSize: 16)),
          contentPadding: const EdgeInsets.all(0),
          value: type,
          groupValue: currTransport,
          onChanged: (TransportType? value) {
            setState(() {
              currTransport = value!;
            });
          }));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> formWidgets = buildTransportTypeRadios();
    formWidgets
      ..insert(
          0,
          const Text(
              "What kind of transportation do you use to commute to school/work?",
              style: TextStyle(fontSize: 16)))
      ..add(ElevatedButton(
          child: const Text("Continue", style: TextStyle(fontSize: 16)),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            if (currTransport == TransportType.none ||
                currTransport == TransportType.zeroEmission) {
              prefs.setString("transportType", currTransport.displayName);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            }
          }));

    return Form(key: _formKey, child: Column(children: formWidgets));
  }
}

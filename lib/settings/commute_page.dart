import 'package:carbon_tracker/homepage.dart';
import 'package:carbon_tracker/settings/settings_page.dart';
import 'package:carbon_tracker/settings/transport_page.dart';
import 'package:carbon_tracker/settings/transport_type.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CommutePage extends StatefulWidget {
  const CommutePage({Key? key}) : super(key: key);

  @override
  State<CommutePage> createState() => _CommutePageState();
}

class _CommutePageState extends State<CommutePage> {
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
                  MaterialPageRoute(
                      builder: (context) => const TransportPage()),
                ),
              ),
              actions: [
                buildHelpButton(
                    context: context,
                    alertTitle: "Commute",
                    description:
                        "Enter your average commute distance each day. Do not include travel outside of going to and from school/work unless you always travel there when you commute. ")
              ]),
          body: const Center(
              child: Padding(
                  child: CommuteForm(),
                  padding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0))),
        ));
  }
}

class CommuteForm extends StatefulWidget {
  const CommuteForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CommuteFormState();
}

class _CommuteFormState extends State<CommuteForm> {
  final _formKey = GlobalKey<FormState>();
  final gasMileageController = TextEditingController();
  final commuteDistanceController = TextEditingController();
  final transportBox = Hive.box('transport');
  late final TransportType transport;

  _CommuteFormState() {
    transport = transportBox.getAt(0)!;
    if (transport.isComplete) {
      if (transport.id == TransportType.car.id) {
        // Reverse emissions calculation to retrieve original mpg
        gasMileageController.text =
            (1 / (transport.emissionsPerMile / 8.887)).toStringAsFixed(1);
      }
      commuteDistanceController.text =
          transport.commuteDistance.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(
              controller: commuteDistanceController,
              decoration: const InputDecoration(
                  labelText:
                      "Average commute distance (include both directions)"),
              validator: (text) {
                if (text == null ||
                    double.tryParse(text) == null ||
                    text.isEmpty) {
                  return "Commute distance must be a number";
                }
              }),
          if (transport.id == TransportType.car.id)
            TextFormField(
                controller: gasMileageController,
                decoration: const InputDecoration(
                    labelText: "Car mpg for gas cars (optional)"),
                validator: (text) => validateGasMileage(text)),
          buildSurveyButton(
            "Submit",
            includePadding: false,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                transport.commuteDistance =
                    double.parse(commuteDistanceController.text);
                if (gasMileageController.text != "") {
                  transport.emissionsPerMile = 1 /
                      (double.parse(gasMileageController.text)) *
                      8.887; // 1/(miles/gallon) * CO2 kg/gallon = CO2 kg/mile
                }
                transport.isComplete = true;
                // Make sure this occurs before routing user back to settings page
                await transportBox.clear();
                await transportBox.add(transport);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              }
            },
          ),
        ]));
  }

  String? validateGasMileage(String? text) {
    if (text == null ||
        (double.tryParse(gasMileageController.text) == null &&
            gasMileageController.text.isNotEmpty)) {
      return "Car mpg must be a number or left blank";
    }
  }
}

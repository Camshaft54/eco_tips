import 'package:eco_tips/settings/commute_page.dart';
import 'package:eco_tips/settings/transport_type.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../homepage.dart';

class TransportPage extends StatefulWidget {
  const TransportPage({Key? key}) : super(key: key);

  @override
  State<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Transport Settings'),
          automaticallyImplyLeading: true,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          actions: [
            buildHelpButton(
              context: context,
              alertTitle: "Commute Method",
              description:
                  "Choose the option that best reflects your commute method. Only one mode of transportation can be selected, so if you commute multiple ways, select the commute method that you use most or the one with greater emissions.",
            ),
          ]),
      body: const Center(
          child: Padding(
              child: TransportForm(),
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0))),
    );
  }
}

class TransportForm extends StatefulWidget {
  const TransportForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TransportFormState();
}

class _TransportFormState extends State<TransportForm> {
  final _formKey = GlobalKey<FormState>();
  var transportBox = Hive.box<TransportType>('transport');
  late TransportType currTransport;

  @override
  void initState() {
    setState(() {
      if (transportBox.isNotEmpty) {
        currTransport = transportBox.getAt(0)!;
      } else {
        currTransport = TransportType.none;
      }
    });
    super.initState();
  }

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
    return Form(
        key: _formKey,
        child: ListView(children: [
          const Text(
              "What kind of transportation do you use to commute to school/work?",
              style: TextStyle(fontSize: 16)),
          ...buildTransportTypeRadios(),
          buildSurveyButton("Continue", includePadding: false, onPressed: () {
            if (currTransport == TransportType.none ||
                currTransport == TransportType.zeroEmission) {
              currTransport.isComplete = true;
              Navigator.pop(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CommutePage()),
              );
            }
            if (transportBox.containsKey(0)) {
              if (transportBox.getAt(0)!.id != currTransport.id) {
                transportBox.putAt(0, currTransport);
              }
            } else {
              transportBox.add(currTransport);
            }
          })
        ]));
  }
}

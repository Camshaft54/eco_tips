
import 'package:carbon_tracker/settings/transport_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../homepage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Carbon Tracker Settings",
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              ),
            ),
          ),
          body: Center(
              child: Padding(padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        child: const Text("Transportation Settings", style: TextStyle(fontSize: 16)),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TransportPage()),
                        )
                      )
                    ]
                  ))),
        ));
  }
}
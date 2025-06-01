import 'package:flutter/material.dart';


/// Class responsible for general settings in the app.
/// Date format
/// Snag terminology

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('General Settings'),
      ),
    );
  }
}

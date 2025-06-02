import 'package:cii/view/utils/text.dart';
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
  // text controllers
  final TextEditingController snagTermController = TextEditingController();
  final TextEditingController snagPluralTermController = TextEditingController();

  // constants
  static const double gap = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextInput("Snag Term", "Snag", snagTermController),
          const SizedBox(height: gap),
          buildTextInput("Snags Term", "Snags", snagPluralTermController),
          const SizedBox(height: gap),
        ]
      )
    );
  }
}

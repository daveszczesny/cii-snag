import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';

class NamingSettings extends StatefulWidget {
  const NamingSettings({super.key});

  @override
  State<NamingSettings> createState() => _NamingSettingsState();
}

class _NamingSettingsState extends State<NamingSettings> {
  // Text controllers
  final TextEditingController snagSingleTermController = TextEditingController();
  final TextEditingController snagPluralTermController = TextEditingController();

  // constants
  static const double gap = 20.0;

  @override
  void initState() {
    super.initState();

    snagSingleTermController.text = AppStrings.snag();
    snagPluralTermController.text = AppStrings.snags();
  }

  // Helper functions

  /* OnClick Function to save User Preferences */
  void onSaveButtonPressed() {
    AppTerminology.singularSnag = snagSingleTermController.text;
    AppTerminology.plurlaSnag = snagPluralTermController.text;

    AppTerminology.saveTerminologyPrefs(AppTerminology.prefsSnag, snagSingleTermController.text);
    AppTerminology.saveTerminologyPrefs(AppTerminology.prefsSnags, snagPluralTermController.text);
    setState((){}); // Save changes
  }
  

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminology Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextInput("Snag", snagSingleTermController.text, snagSingleTermController),
            const SizedBox(height: gap),
            buildTextInput("Snags", snagPluralTermController.text, snagPluralTermController),
            const SizedBox(height: gap),
            buildTextButton("Save Preferences", onSaveButtonPressed)
          ]
        )
      )
    );
  }
}
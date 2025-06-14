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

  /* Function to save User Preferences */
  void saveChanges() {

    if (AppTerminology.singularSnag != snagSingleTermController.text ||
        AppTerminology.plurlaSnag != snagPluralTermController.text) {
          // Show a snack bar to ind  icate changes have been made
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terminology changes saved!'),
          duration: Duration(seconds: 2),
        )
      );
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Save changes and navigate back
            saveChanges();
            Navigator.pop(context);
          }
        )
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
          ]
        )
      )
    );
  }
}
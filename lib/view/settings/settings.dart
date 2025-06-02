import 'package:cii/view/settings/datetime_settings.dart';
import 'package:cii/view/settings/naming_settings.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

Widget settingsTab(BuildContext context, String label, StatefulWidget w) {
  return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: TextButton(
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
        ),
        onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => w)
          );
        },
        child: Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left,
        )
      ),
    );
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          settingsTab(context, "Terminology", const NamingSettings()),
          const SizedBox(height: 12.0),
          settingsTab(context, "Date Time Format", const DateTimeSettings()),
        ]
      ),
    );
  }
}
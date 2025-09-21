import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _NamingSettingsState();
}

class _NamingSettingsState extends State<AppSettings> {
  // Text controllers
  final TextEditingController dueDateReminder = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    await AppDueDateReminder.loadDueDateReminderPrefs();
    setState(() {
      dueDateReminder.text = AppDueDateReminder.dueDateReminderDays.toString();
    });
  }


  /* Function to save User Preferences */
  void saveChanges() async {
    final days = int.tryParse(dueDateReminder.text) ?? 14;
    if (AppDueDateReminder.dueDateReminderDays != days) {
      await AppDueDateReminder.saveDueDateReminderPrefs(days);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App settings updated'),
            duration: Duration(seconds: 2),
          )
      );
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
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
            buildNumericInput(
              'Due Date Reminder (Days)', 
              'Enter number of days before due date', 
              dueDateReminder
            ),
            const SizedBox(height: 8),
            const Text(
              'Set how many days before the due date you want to be reminded',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ]
        )
      )
    );
  }
}
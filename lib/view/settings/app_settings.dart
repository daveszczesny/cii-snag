import 'package:cii/view/settings/utils/common.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  // Text controllers
  final TextEditingController dueDateReminder = TextEditingController();

  // Date Time Formats
  String selectedPattern = AppDateTimeFormat.dateTimeFormatPattern;

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
    bool changed = false;
    if (AppDueDateReminder.dueDateReminderDays != days) {
      await AppDueDateReminder.saveDueDateReminderPrefs(days);
      changed = true;
    }
    if (selectedPattern != AppDateTimeFormat.dateTimeFormatPattern) {
      AppDateTimeFormat.saveDateTimePrefs(selectedPattern);
      changed = true;
    }

    if(changed){
      showSnackBar();
    }
    Navigator.pop(context);
  }

  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('App settings updated'),
        duration: Duration(seconds: 2),
      )
    );
  }

  Widget buildDueDateReminder() {
    return Column(
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
    );
  }

  Widget buildDateTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Date Format', style: TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
          ],
        ),
        GestureDetector(
          onTap: () async {
            final selected = await showModalBottomSheet<String>(
              context: context,
              builder: (context) {
                int tempIndex = formats.indexWhere((f) => f['pattern'] == selectedPattern);
                return SizedBox(
                  height: 250,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel', style: TextStyle(fontSize: 14, fontFamily: 'Roboto')),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, formats[tempIndex]['pattern']),
                              child: const Text('Done', style: TextStyle(fontSize: 14, fontFamily: 'Roboto')),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(initialItem: tempIndex),
                          itemExtent: 40,
                          onSelectedItemChanged: (index) {
                            tempIndex = index;
                          },
                          children: formats.map((f) => Center(child: Text(f['label']!))).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
            if (selected != null && selected != selectedPattern) {
              setState(() {
                selectedPattern = selected;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF333333))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formats.firstWhere((f) => f['pattern'] == selectedPattern)['label']!,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Roboto'),
                ),
                const Icon(Icons.arrow_drop_down, color: Color(0xFF333333)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose your preferred date format',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
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
            buildDueDateReminder(),
            const SizedBox(height: 16),
            buildDateTime(),
          ]
        )
      )
    );
  }

  
}
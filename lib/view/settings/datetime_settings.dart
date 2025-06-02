import 'package:cii/view/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DateTimeSettings extends StatefulWidget {
  const DateTimeSettings({super.key});

  @override
  State<DateTimeSettings> createState() => _DateTimeSettingsState();
}

class _DateTimeSettingsState extends State<DateTimeSettings> {


  // supported formats
  final List<Map<String, String>> formats = [
    {'label': 'dd/MM/YYYY', 'pattern': 'dd/MM/yyyy'},
    {'label': 'YYYY/MM/dd', 'pattern': 'yyyy/MM/dd'},
    {'label': 'MM/dd/YYYY', 'pattern': 'MM/dd/yyyy'}
  ];

  String selectedPattern = AppDateTimeFormat.dateTimeFormatPattern;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Date Format Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Date Format'),
              subtitle: Text(formats.firstWhere((f) => f['pattern'] == selectedPattern)['label']!),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () async {
                final selected = await showModalBottomSheet<String>(
                  context: context,
                  builder: (context) {
                    int tempIndex = formats.indexWhere((f) => f['pattern'] == selectedPattern);
                    return SizedBox(
                      height: 250,
                      child: Column(
                        children: [
                          // Top bar with Cancel and Done
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context), // Cancel
                                  child: const Text('Cancel', style: TextStyle(fontSize: 14, fontFamily: 'Roboto')),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, formats[tempIndex]['pattern']), // Done
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
                    AppDateTimeFormat.saveDateTimePrefs(selectedPattern);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date, String pattern) {
    // Simple manual formatting for demonstration
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String year = date.year.toString();
    String month = twoDigits(date.month);
    String day = twoDigits(date.day);

    if (pattern == 'dd/MM/yyyy') {
      return '$day/$month/$year';
    } else if (pattern == 'MM/dd/yyyy') {
      return '$month/$day/$year';
    }
    return '$day/$month/$year';
  }
}
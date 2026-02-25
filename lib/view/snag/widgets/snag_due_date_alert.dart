import 'package:cii/models/snag.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';

class SnagDueDateAlert extends StatelessWidget {
  final Snag snag;

  const SnagDueDateAlert({super.key, required this.snag});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppDueDateReminder.version,
      builder: (context, _, __) {
        if (snag.dueDate == null) {
          return const SizedBox.shrink();
        }

        final dueDateTime = snag.dueDate!;
        final now = DateTime.now();
        final dueDate = DateTime(dueDateTime.year, dueDateTime.month, dueDateTime.day);
        final today = DateTime(now.year, now.month, now.day);
        final timeDelta = dueDate.difference(today).inDays;

        if (timeDelta > AppDueDateReminder.dueDateReminderDays - 1 || timeDelta < 0) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            border: Border.all(color: Colors.orange, width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange, size: 20.0),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  timeDelta == 0
                      ? "Due Today!"
                      : "Due in $timeDelta day(s)",
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500)
                )
              )
            ]
          )
        );
      }
    );
  }
}
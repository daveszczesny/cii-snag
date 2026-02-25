import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';

class SnagFormSection extends StatelessWidget {
  final Snag snag;
  final bool isEditable;
  final Map<String, TextEditingController> controllers;


  const SnagFormSection({
    super.key,
    required this.snag,
    required this.isEditable,
    required this.controllers
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditable) ... [
            _buildEditableForm(context)
          ] else ... [
            _buildReadOnlyForm(context)
          ]
        ],
      )
    );
  }

  Widget _buildEditableForm(BuildContext context) {
    const double gap = 16.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextDetail("ID", snag.id),
        const SizedBox(height: gap),
        buildLimitedTextInput(AppStrings.snagName(), snag.name, controllers["name"]!, 40),
        const SizedBox(height: gap),
        buildLongTextInput("Description", snag.description, controllers["description"]),
        const SizedBox(height: gap),
        buildTextDetail("Date Created", formatDate(snag.dateCreated)),
        const SizedBox(height: gap),
        buildTextInput("Assignee", snag.assignee ?? "", controllers["assignee"]!),
        const SizedBox(height: gap),
        buildTextInput("Location", snag.location ?? "", controllers["location"]!),
        const SizedBox(height: gap),
        buildDatePickerInput(
          context,
          "Due Date",
          snag.dueDate != null ? formatDate(snag.dueDate!) : "-",
          controllers["dueDate"]!
        ),
        const SizedBox(height: gap),
        if (snag.status == Status.completed) ... [
          buildTextInput("Reviewed By", snag.reviewedBy ?? "", controllers["reviewedBy"]!),
          const SizedBox(height: gap),
          buildTextInput("Final Remarks", snag.finalRemarks ?? "", controllers["finalRemarks"]!)
        ]
      ],
    );
  }


  Widget _buildReadOnlyForm(BuildContext context) {
    const double gap = 16.0;
    final dateClosed = snag.dateClosed != null
      ? formatDate(snag.dateClosed!)
      : "-";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextDetail("ID", snag.id),
          const SizedBox(height: gap),
          buildTextDetail("${AppStrings.snag()} Name", snag.name),
          const SizedBox(height: gap),
          buildJustifiedTextDetail("Description", !isNullorEmpty(snag.description)
            ? snag.description!
            : "-"
          ),
          const SizedBox(height: gap),
          buildTextDetail("Date Created", formatDate(snag.dateCreated)),
          const SizedBox(height: gap),
          buildTextDetail("Assignee", !isNullorEmpty(snag.assignee) ? snag.assignee! : "-"),
          const SizedBox(height: gap),
          buildTextDetail("Location", !isNullorEmpty(snag.location) ? snag.location! : "-"),
          const SizedBox(height: gap),
          _buildDueDateWithAlert(),
          const SizedBox(height: gap),
          if (snag.status == Status.completed) ... [
            const SizedBox(height: gap),
            buildTextDetail("Date Closed", dateClosed),
            const SizedBox(height: gap),
            buildTextDetail("Reviewed By", snag.reviewedBy ?? "-"),
            const SizedBox(height: gap),
            buildTextDetail("Final Remarks", snag.finalRemarks ?? "-")
          ]
        ]
      );
  }


  Widget _buildDueDateWithAlert() {
    final dueDate = snag.dueDate != null ? formatDate(snag.dueDate!) : '-';
    var dueDateSubtext = '';
    Icon? dueDateIcon;

    if (snag.dueDate != null && snag.status.name != Status.completed.name) {
      final dueDateTime = snag.dueDate!;
      final now = DateTime.now();
      final diff = dueDateTime.difference(now).inDays;
      const iconSize = 16.0;

      if (diff < 0) {
        dueDateSubtext = 'Overdue by ${diff.abs()} days';
        dueDateIcon = Icon(Icons.warning, size: iconSize, color: Colors.red.withOpacity(0.8));
      } else if (diff == 0) {
        dueDateSubtext = 'Due today';
        dueDateIcon = Icon(Icons.schedule, size: iconSize, color: Colors.orange.withOpacity(0.8));
      } else {
        dueDateSubtext = '${diff + 1} days left';
        if (diff <= 7) {
          dueDateIcon = Icon(Icons.schedule, size: iconSize, color: Colors.orange.withOpacity(0.8));
        } else if (diff <= 14) {
          dueDateIcon = Icon(Icons.schedule, size: iconSize, color: Colors.green.withOpacity(0.8));
        } else {
          dueDateIcon = null; // No icon for more than 14 days
        }
      }

    }

    return buildTextDetailWithIcon('Due Date', dueDate, dueDateIcon, subtext: dueDateSubtext);
  }
}
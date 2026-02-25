import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';

class SnagStatusSection extends StatelessWidget {
  final String label;
  final List<String> statusOptions;
  final ValueNotifier<String> selectedStatusOption;
  final bool isEditable;

  const SnagStatusSection({
    super.key,
    required this.label,
    required this.statusOptions,
    required this.selectedStatusOption,
    required this.isEditable
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildCustomSegmentedControl(
          label: label,
          options: statusOptions,
          selectedNotifier: selectedStatusOption,
          enabled: !isEditable
        )
      ],
    );
  }
}
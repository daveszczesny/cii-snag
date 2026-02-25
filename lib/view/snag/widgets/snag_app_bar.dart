import 'package:cii/models/snag.dart';
import 'package:cii/services/snag_service.dart';
import 'package:cii/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnagAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Snag snag;
  final bool isEditable;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onToggleEdit;
  final VoidCallback? onStatusChanged;

  const SnagAppBar({
    super.key,
    required this.snag,
    required this.isEditable,
    required this.controllers,
    required this.onToggleEdit,
    required this.onStatusChanged
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(snag.name),
      leading: _buildLeading(context),
      actions: [_buildAction(context, ref)]
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (!isEditable) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context)
      );
    }

    return GestureDetector(
      onTap: () => _handleCancel(context),
      child: const Icon(Icons.close)
    );
  }


  Widget _buildAction(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
       child: GestureDetector(
        onTap: () => _handleAction(context, ref),
        child: isEditable ? const Icon(Icons.check) : const Text("Edit"),
       )
    );
  }

  void _handleCancel(BuildContext context) {
    if (_hasChanges()) {
      _showDiscardDialog(context);
    } else {
      onToggleEdit();
    }
  }

  void _handleAction(BuildContext context, WidgetRef ref) {
    if (isEditable) {
      _saveChanges(ref);
    } else {
      _enterEditMode();
    }
    onToggleEdit();
  }

  bool _hasChanges() {
    return (controllers["name"]!.text.isNotEmpty && controllers["name"]!.text != snag.name) ||
      (controllers["description"]!.text.isNotEmpty && controllers["description"]!.text != snag.description) ||
      (controllers["assignee"]!.text.isNotEmpty && controllers["assignee"]!.text != snag.assignee) ||
      (controllers["location"]!.text.isNotEmpty && controllers["location"]!.text != snag.location) ||
      (controllers["dueDate"]!.text != '' && snag.dueDate != null && controllers["dueDate"]!.text != formatDate(snag.dueDate!));
  }

  void _showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Discard Changes"),
        content: const Text("Are you sure you want to discard the changes?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onToggleEdit();
            },
            child: const Text("Discard")
          )
        ]
      )
    );
  }

  void _saveChanges(WidgetRef ref) {
    final updatedSnag = snag.copyWith(
      name: controllers["name"]!.text.isNotEmpty ? controllers["name"]!.text : snag.name,
      description: controllers["description"]!.text.trim(),
      assignee: controllers["assignee"]!.text,
      location: controllers["location"]!.text,
      dueDate: controllers["dueDate"]!.text != '' ? parseDate(controllers["dueDate"]!.text) : snag.dueDate,
      reviewedBy: controllers["reviewedBy"]!.text,
      finalRemarks: controllers["finalRemarks"]!.text
    );
    SnagService.updateSnag(ref, updatedSnag);
    onStatusChanged?.call();
  }

  void _enterEditMode() {
    controllers["name"]!.text = snag.name;
    controllers["description"]!.text = snag.description ?? "";
    controllers["assignee"]!.text = snag.assignee ?? "";
    controllers["location"]!.text = snag.location ?? "";
    controllers["dueDate"]!.text = snag.dueDate != null
      ? formatDate(snag.dueDate!)
      : "";
    controllers["reviewedBy"]!.text = snag.reviewedBy ?? "";
    controllers["finalRemarks"]!.text = snag.finalRemarks ?? "";
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}
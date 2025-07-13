import 'dart:io';

import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/controllers/snag_controller.dart';
import 'package:cii/models/status.dart';
import 'package:cii/utils/colors/app_colors.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/snag/snag_detail.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';

class SnagCardWidget extends StatefulWidget {
  final SingleProjectController projectController;
  final SnagController snagController;
  final VoidCallback onStatusChanged;

  const SnagCardWidget({
    super.key,
    required this.projectController,
    required this.snagController,
    required this.onStatusChanged,
  });

  @override
  State<SnagCardWidget> createState() => _SnagCardWidgetState();
}

class _SnagCardWidgetState extends State<SnagCardWidget> {

  List<String> finalImagePaths = [];

  void _showStatusModal(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: FractionallySizedBox(
            heightFactor: 0.7,
            child: Column(
              children: Status.values
              .map((status) {
                return ListTile(
                  title: Text(status.name),
                  onTap: () async {
                    Navigator.pop(context); // Close the bottom sheet first
                    if (status.name == Status.completed.name) {
                      await Future.delayed(const Duration(milliseconds: 200)); // Wait for the sheet to close
                      final width = MediaQuery.of(parentContext).size.width * 0.95;
                      final height = MediaQuery.of(parentContext).size.height * 0.8;
                      await buildFinalRemarksWidget(
                        parentContext,
                        widget.snagController,
                        widget.projectController,
                        widget.onStatusChanged,
                        List<String>.from(finalImagePaths),
                        width: width,
                        height: height
                      );
                      
                    } else {
                      setState(() {
                        widget.snagController.status = status;
                      });
                      widget.onStatusChanged();
                    }
                  },
                );
              }).toList(),
            )
          )
        );
      },
    );
  }

  void _showCategoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      builder: (BuildContext context) {
        widget.projectController.sortCategories();
        final categories = widget.projectController.getCategories!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: FractionallySizedBox(
            heightFactor: 0.7,
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return ListTile(
                  title: Text(cat.name),
                  onTap: () {
                    setState(() {
                      widget.snagController.setCategory(cat);
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      }
    );
  }

  // Handles popup menu selection
  void onSelect(String value) {
    switch (value) {
      case 'view':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SnagDetail(
            projectController: widget.projectController,
            snag: widget.snagController,
            onStatusChanged: widget.onStatusChanged
          ))
        );
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Delete ${AppStrings.snag()}'),
              content: Text('Are you sure you want to delete this ${AppStrings.snag().toLowerCase()}?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(AppStrings.cancel)
                ),
                TextButton(
                  onPressed: () {
                    widget.projectController.deleteSnag(widget.snagController.snag);
                    widget.onStatusChanged();
                    Navigator.of(context).pop();
                  },
                  child: const Text(AppStrings.delete)
                ),
              ],
            );
          }
        );
        break;
    }
  }

  Widget gesturePill(VoidCallback tap, Color color, String text, {bool borderOnly = false}){

    const double pillWidth = 9;
    const double pillHeight = 4;
    
    if (borderOnly) {
      return GestureDetector(
        onTap: tap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: pillWidth, vertical: pillHeight),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 0.5),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100), // Set your max width here
            child: Text(
              text,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: pillWidth, vertical: pillHeight),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 0.5),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100), // Set your max width here
          child: Text(
            text,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  // Helper method for due date
  Widget? _buildDueDatePill() {
    final dueDate = widget.snagController.getDueDate;
    if (dueDate == null) return null;

    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;

    if (diff < -1) {
      // overdue
      return gesturePill(() {}, Colors.red.withOpacity(0.8), 'Overdue');
    } else if (diff <= 7) {
      // due soon
      return gesturePill((){}, Colors.orange.withOpacity(0.8), '${diff}d left');
    }
    return null;
  }

  Widget? _buildDueDateIcon() {
    final dueDate = widget.snagController.getDueDate;
    if (dueDate == null) return null;
    
    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;
    const iconSize = 18.0;
    if (diff < -1) {
      return const Icon(Icons.warning, size: iconSize, color: Colors.red);
    } else if (diff <= 7) {
      return const Icon(Icons.schedule, size: iconSize, color: Colors.orange);
    } else if (diff <= 14) {
      return const Icon(Icons.schedule, size: iconSize, color: Colors.green);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.snagController.status;
    final assignee = widget.snagController.assignee != '' ? widget.snagController.assignee : 'Unassigned';

    const unassignedIcon = 'lib/assets/icons/png/assignee_unassigned.png';
    const assignedIcon = 'lib/assets/icons/png/assignee_assigned.png';

    final assigneeIcon = assignee == 'Unassigned' ? unassignedIcon : assignedIcon;
    const double assigneeIconSize = 16;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SnagDetail(
              projectController: widget.projectController,
              snag: widget.snagController,
              onStatusChanged: widget.onStatusChanged,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        // Card outline
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, spreadRadius: 2, offset: const Offset(0, 0))
          ]
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image or grey box
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: (() {
                      // Check if the image path is not null and the file exists
                      // If it does, display the image; otherwise, display a grey box
                      final imagePaths = widget.snagController.imagePaths;
                      if (imagePaths.isNotEmpty && imagePaths[0].isNotEmpty && File(imagePaths[0]).existsSync()) {
                        return Image.file(File(imagePaths[0]), width: 75, height: 75, fit: BoxFit.cover);
                      } else {
                        return Container(width: 75, height: 75, color: Colors.grey[300], child: const Icon(Icons.image, color: Colors.white54, size: 36));
                      }
                    })(),
                  ),
                  const SizedBox(width: 14),
                  // Project info column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(widget.snagController.priority.icon, width: 16, height: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.snagController.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black, fontFamily: 'Roboto'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(assignee, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.black, fontFamily: 'Roboto')),
                            const SizedBox(width: 4),
                            Image.asset(assigneeIcon, width: assigneeIconSize, height: assigneeIconSize),
                          ],
                        ),

                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // status pill
                            gesturePill(() => _showStatusModal(context), (status.color ?? Colors.blue).withOpacity(0.5), status.name),
                            const SizedBox(width: 8),
                            // Category pill
                            if (widget.snagController.categories.isNotEmpty) ...[
                              gesturePill(() => _showCategoryModal(context), Colors.black, widget.snagController.categories[0].name, borderOnly: true),
                            ],
                            if (_buildDueDateIcon() != null) ... [
                              const SizedBox(width: 8),
                              _buildDueDateIcon()!
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40), // Reserve space for chevron
                ],
              ),
            ),
            // PopupMenuButton at top right
            Positioned(
              top: 0,
              right: 0,
              child: PopupMenuButton<String>(
                onSelected: onSelect,
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'view',
                      child: Text(AppStrings.viewSnag()),
                    ),
                    const PopupMenuDivider(height: 1.0),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(AppStrings.deleteSnag(), style: const TextStyle(color: AppColors.red)),
                    ),
                  ];
                },
              ),
            ),
            // Chevron icon vertically centered at right
            const Positioned(right: 8, top: 14, bottom: 0,
              child: Center(child: Icon(Icons.chevron_right, size: 32, color: Colors.black38)),
            ),
          ],
        ),
      ),
    );
  }
}
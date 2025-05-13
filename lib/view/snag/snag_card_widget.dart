import 'dart:io';

import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/controllers/snag_controller.dart';
import 'package:cii/models/status.dart';
import 'package:cii/utils/colors/app_colors.dart';
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

  void _showStatusModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
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
                  onTap: () {
                    setState(() {
                      widget.snagController.status = status;
                    });
                    widget.onStatusChanged();
                    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SnagDetail(
            projectController: widget.projectController,
            snag: widget.snagController,
            onStatusChanged: widget.onStatusChanged))
        );
      },
      child: SizedBox(
        height: 110,
        child: Card(
          color: AppColors.cardColor,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey,
                  child: widget.snagController.imagePaths.isEmpty
                   ? const Icon(Icons.image, color: Colors.white)
                   : Image.file(
                      File(widget.snagController.imagePaths[0]),
                      fit: BoxFit.cover,
                    ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            widget.snagController.priority.icon,
                            width: 16.0,
                            height: 16.0,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              widget.snagController.name,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                                fontFamily: 'Roboto',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          // ...status pill...
                          GestureDetector(
                            onTap: () => _showStatusModal(context),
                            child: Container(
                              width: 90,
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Status.getStatus(widget.snagController.status.name, context)!.color,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                widget.snagController.status.name,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  fontFamily: 'Roboto',
                                )
                              )
                            )
                          ),

                          // Category pill (show only if categories is not empty)
                          if (widget.snagController.categories.isNotEmpty) ... [
                            const SizedBox(width: 8.0),
                            GestureDetector(
                              onTap: () => _showCategoryModal(context),
                              child: Container(
                                width: 90,
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: widget.snagController.categories[0].color,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  widget.snagController.categories[0].name, // Show category name, not status
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                  )
                                )
                              )
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        // Handle menu actions
                        switch (value) {
                          case 'view':
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => SnagDetail(projectController: widget.projectController, snag: widget.snagController))
                            );
                            break;
                          case 'share':
                            break;
                          case 'edit':
                            break;
                          case 'delete':
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Snag'),
                                  content: const Text('Are you sure you want to delete this snag?'),
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
                      },
                      // Quick actions for a selected project
                      itemBuilder: (BuildContext context) {
                        return const [
                          PopupMenuItem<String>(
                            value: 'view',
                            child: Text(AppStrings.viewSnag),
                          ),
                          PopupMenuItem<String>(
                            value: 'share',
                            child: Text(AppStrings.shareSnag),
                          ),
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Text(AppStrings.editSnag),
                          ),
                          PopupMenuDivider(
                            height: 1.0,
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text(AppStrings.deleteSnag, style: TextStyle(color: AppColors.red)),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
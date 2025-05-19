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

  // Handles popup menu selection
  void onSelect(String value) {
    switch (value) {
      case 'view':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SnagDetail(projectController: widget.projectController, snag: widget.snagController))
        );
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
  }

  Widget gesturePill(VoidCallback tap, Color color, String text){
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 14)),
      )
    );
  }

  @override
  Widget old_build(BuildContext context) {
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
      child: SizedBox(
        height: 110,
        child: Card(
          color: Theme.of(context).cardColor,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (widget.snagController.imagePaths.isNotEmpty) ... [
                      Container(
                        width: 50, height: 50, color: Colors.grey,
                        child: Image.file(File(widget.snagController.imagePaths[0]), width: 50, height: 50, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 16.0),
                    ],
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
                              // Status pill
                              GestureDetector(
                                onTap: () => _showStatusModal(context),
                                child: Container(
                                  width: 90,
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Status.getStatus(widget.snagController.status.name)!.color,
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
                                    ),
                                  ),
                                ),
                              ),
                              // Category pill (show only if categories is not empty)
                              if (widget.snagController.categories.isNotEmpty) ...[
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
                                      widget.snagController.categories[0].name,
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: PopupMenuButton<String>(
                  onSelected: onSelect,
                  itemBuilder: (BuildContext context) {
                    return const [
                      PopupMenuItem<String>(
                        value: 'view',
                        child: Text(AppStrings.viewSnag),
                      ),
                      // PopupMenuItem<String>( // TODO: remove share option for now (until Version 2.0)
                      //   value: 'share',
                      //   child: Text(AppStrings.shareSnag),
                      // ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final status = widget.snagController.status;

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
                            Text(
                              widget.snagController.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black, fontFamily: 'Roboto'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            // status pill
                            gesturePill(() => _showStatusModal(context), Colors.black, status.name),
                            const SizedBox(width: 8),
                            // Category pill
                            if (widget.snagController.categories.isNotEmpty) ... [
                              gesturePill(() => _showCategoryModal(context), widget.snagController.categories[0].color, widget.snagController.categories[0].name),
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
                    const PopupMenuItem<String>(
                      value: 'view',
                      child: Text(AppStrings.viewSnag),
                    ),
                    const PopupMenuDivider(height: 1.0),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(AppStrings.deleteSnag, style: TextStyle(color: AppColors.red)),
                    ),
                  ];
                },
              ),
            ),
            // Chevron icon vertically centered at right
            const Positioned(
              right: 8,
              top: 14,
              bottom: 0,
              child: Center(
                child: Icon(Icons.chevron_right, size: 32, color: Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }




}
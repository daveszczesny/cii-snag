import 'dart:io';

import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/status.dart';
import 'package:cii/services/pdf_exporter.dart';
import 'package:cii/utils/colors/app_colors.dart';
import 'package:cii/view/project/project_detail.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';

class ProjectCardWidget extends StatefulWidget {
  final SingleProjectController projectController;

  const ProjectCardWidget({super.key, required this.projectController});

  @override
  State<ProjectCardWidget> createState() => _ProjectCardWidgetState();
}

class _ProjectCardWidgetState extends State<ProjectCardWidget> {

  @override
  void initState() {
    super.initState();
  }

  void onSelect(String value) {
    switch (value) {
      case 'view':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProjectDetail(projectController: widget.projectController))
        );
        break;
      case 'add':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProjectDetail(projectController: widget.projectController, index: 2))
        );
        break;
      case 'export':
        // implement share functionality
          savePdfFile(widget.projectController);
        break;
      case 'delete':
        // implement delete functionality
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(AppStrings.deleteProject),
              content: const Text(AppStrings.deleteProjectConfirmation),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(AppStrings.cancel)
                ),
                TextButton(
                  onPressed: () {
                    widget.projectController.deleteProject();
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


@override
  Widget old_build(BuildContext context){
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProjectDetail(projectController: widget.projectController))
        );
      },
      child: Card(
        color: Theme.of(context).cardColor,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: SizedBox(
          height: 120, // Adjust height as needed
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (widget.projectController.getMainImagePath != null && widget.projectController.getMainImagePath != '') ...[
                      Container(
                        width: 75, height: 75, color: Colors.grey,
                        child: Image.file(File(widget.projectController.getMainImagePath!), width: 75, height: 75, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 16.0),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(), // Pushes the text to vertical center
                          Text(
                            widget.projectController.getName!,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          const Spacer(), // Pushes the progress bar to the bottom
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
                            child: widget.projectController.getSnags!.isEmpty
                                ? const Text(AppStrings.noSnagsFound)
                                : (widget.projectController.getSnagProgress() == 1
                                    ? const Text('All snags completed', style: TextStyle(color: AppColors.primaryGreen))
                                    : Row(
                                        children: [
                                          // The progress bar takes up all space except for the popup menu
                                          Expanded(
                                            child: LinearProgressIndicator(
                                              value: widget.projectController.getSnagProgress(),
                                              color: Color.lerp(
                                                Colors.blue,
                                                Colors.green,
                                                widget.projectController.getSnagProgress(),
                                              ),
                                            ),
                                          ),
                                          // Reserve space for the popup menu button (adjust width as needed)
                                          const SizedBox(width: 48),
                                        ],
                                      )),
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
                    return [
                      const PopupMenuItem<String>(
                        value: 'view',
                        child: Text(AppStrings.viewProject)
                      ),
                      const PopupMenuItem<String>(
                        value: 'add',
                        child: Text(AppStrings.addSnag)
                      ),
                      const PopupMenuItem<String>(
                        value: 'export',
                        child: Text(AppStrings.shareProject)
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text(AppStrings.editProject)
                      ),
                      const PopupMenuDivider(height: 1.0),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(AppStrings.deleteProject, style: TextStyle(color: AppColors.red)),
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
    final snagCount = widget.projectController.getTotalSnags();
    final completed = widget.projectController.getTotalSnagsByStatus(Status.completed);
    final inProgress = widget.projectController.getTotalSnagsByStatus(Status.inProgress);
    final todo = widget.projectController.getTotalSnagsByStatus(Status.todo);
    final onHold = widget.projectController.getTotalSnagsByStatus(Status.blocked);
    final status = widget.projectController.getStatus ?? Status.todo.name;

    final total = completed + inProgress + todo + onHold;
    double percent(int count) => total == 0 ? 0 : count / total;
    final completedPercent = percent(completed);
    final inProgressPercent = percent(inProgress);
    final todoPercent = percent(todo);
    final onHoldPercent = percent(onHold);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProjectDetail(projectController: widget.projectController))
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, spreadRadius: 2, offset: const Offset(0, 0))
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
                      final path = widget.projectController.getMainImagePath;
                      if (path != null && path.isNotEmpty && File(path).existsSync()) {
                        return Image.file(File(path), width: 75, height: 75, fit: BoxFit.cover);
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
                        Text(
                          widget.projectController.getName ?? '',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black, fontFamily: 'Roboto'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text('$snagCount snags', style: const TextStyle(fontSize: 14, color: Colors.black87, fontFamily: 'Roboto')),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: (Status.getStatus(status)!.color ?? Colors.blue).withOpacity(0.5), 
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: Text(status, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Stacked progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.transparent,
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double width = constraints.maxWidth;
                                double start = 0;

                                List<Widget> bars = [];

                                void addBar(double percent, Color color) {
                                  if (percent > 0) {
                                    final barWidth = width * percent;
                                    bars.add(Positioned(
                                      left: start,
                                      child: Container(
                                        width: barWidth,
                                        height: 8,
                                        color: color,
                                      ),
                                    ));
                                    start += barWidth;
                                  }
                                }

                                // Order: green (completed), yellow (in progress), white (todo), red (on hold)
                                addBar(completedPercent, Colors.green);
                                addBar(inProgressPercent, Colors.yellow);
                                addBar(todoPercent, Colors.white);
                                addBar(onHoldPercent, Colors.red);

                                return Stack(children: bars);
                              },
                            ),
                          ),
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
                      child: Text(AppStrings.viewProject),
                    ),
                    const PopupMenuItem<String>(
                      value: 'add',
                      child: Text(AppStrings.addSnag),
                    ),
                    const PopupMenuItem<String>(
                      value: 'export',
                      child: Text(AppStrings.shareProject),
                    ),
                    const PopupMenuDivider(height: 1.0),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(AppStrings.deleteProject, style: TextStyle(color: AppColors.red)),
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
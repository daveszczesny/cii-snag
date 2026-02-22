import 'dart:io';
import 'package:cii/models/project.dart';
import 'package:cii/models/status.dart';
import 'package:cii/providers/providers.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/utils/colors/app_colors.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/project/export/project_export.dart';
import 'package:cii/view/project/project_detail.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectCardWidget extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectCardWidget({super.key, required this.projectId});

  @override
  ConsumerState<ProjectCardWidget> createState() => _ProjectCardWidgetState();
}

class _ProjectCardWidgetState extends ConsumerState<ProjectCardWidget> {

  @override
  void initState() {
    super.initState();
  }

  void onSelect(String value) {
    switch (value) {
      case 'view':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProjectDetail(projectId: widget.projectId, index: 1))
        );
        break;
      case 'add':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProjectDetail(projectId: widget.projectId, index: 2))
        );
        break;
      case 'export':
        // implement share functionality
          // savePdfFile(widget.projectController);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ProjectExport(projectId: widget.projectId))
          );
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
                    ProjectService.deleteProject(ref, widget.projectId);
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
  Widget build(BuildContext context) {
    final Project project = ProjectService.getProject(ref, widget.projectId);

    ProjectService.getSnags(ref, widget.projectId); // Watches snag changes

    final int snagCount = ProjectService.getSnagCount(ref, widget.projectId);
    final int completed = ProjectService.getSnagsByStatus(ref, widget.projectId, Status.completed).length;
    final int inProgress = ProjectService.getSnagsByStatus(ref, widget.projectId, Status.inProgress).length;
    final int todo = ProjectService.getSnagsByStatus(ref, widget.projectId, Status.todo).length;
    final int onHold = ProjectService.getSnagsByStatus(ref, widget.projectId, Status.blocked).length;
    final String status = project.status.name;

    final total = completed + inProgress + todo + onHold;
    double percent(int count) => total == 0 ? 0 : count / total;
    final completedPercent = percent(completed);
    final inProgressPercent = percent(inProgress);
    final todoPercent = percent(todo);
    final onHoldPercent = percent(onHold);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProjectDetail(projectId: project.id!))
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
                      final path = project.mainImagePath;
                      if (path != null && path.isNotEmpty) {
                        return FutureBuilder<String>(
                          future: getImagePath(path),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || !File(snapshot.data!).existsSync()) {
                              return Container(width: 75, height: 75, color: Colors.grey[300], child: const Icon(Icons.image, color: Colors.white54, size: 36));
                            }
                            return Container(
                              width: 75,
                              height: 75,
                              child: Image.file(File(snapshot.data!), fit: BoxFit.cover),
                            );
                          },
                        );
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
                          project.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black, fontFamily: 'Roboto'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text('$snagCount ${AppStrings.snags()}', style: const TextStyle(fontSize: 14, color: Colors.black87, fontFamily: 'Roboto')),
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
                    PopupMenuItem<String>(
                      value: 'add',
                      child: Text(AppStrings.addSnag()),
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

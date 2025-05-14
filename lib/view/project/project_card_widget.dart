import 'dart:io';

import 'package:cii/controllers/single_project_controller.dart';
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
          savePdfFile();
        break;
      case 'edit':
        // implement edit functionality
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
  Widget build(BuildContext context){
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
}
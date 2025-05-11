import 'dart:io';

import 'package:cii/controllers/single_project_controller.dart';
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

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: () {
        // Navigate to the project details view
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProjectDetail(projectController: widget.projectController))
        );
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                color: Colors.grey,
                child: widget.projectController.getMainImagePath != null
                  ? Image.file(
                      File(widget.projectController.getMainImagePath!),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                    : const Icon(Icons.image, color: Colors.white),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.projectController.getName!,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        widget.projectController.getSnags!.isEmpty
                          ? const Text(AppStrings.noSnagsFound)
                          : LinearProgressIndicator(
                            value: widget.projectController.getSnagProgress(),
                            color: Colors.blue,
                          ),

                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      // handle menu item selections
                      switch (value) {
                        case 'view':
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => ProjectDetail(projectController: widget.projectController))
                          );
                          break;
                        case 'add':
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => ProjectDetail(projectController: widget.projectController, index: 1))
                          );
                          break;
                        case 'share':
                          // implement share functionality
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
                    },
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
                          value: 'share',
                          child: Text(AppStrings.shareProject)
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text(AppStrings.editProject)
                        ),
                        const PopupMenuDivider(height: 1.0),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(AppStrings.deleteProject)
                        ),
                      ];
                    },
                  )
            ]
          )
        )
      )
    );
  }
}
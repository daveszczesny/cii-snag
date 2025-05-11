import 'dart:io';

import 'package:cii/controllers/single_project_controller.dart';
import 'package:flutter/material.dart';

class ProjectCardWidget extends StatefulWidget {
  final SingleProjectController projectController;

  const ProjectCardWidget({
    super.key,
    required this.projectController,
  });

  @override
  State<ProjectCardWidget> createState() => _ProjectCardWidgetState();
}

class _ProjectCardWidgetState extends State<ProjectCardWidget> {
  late SingleProjectController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: () {
        // Navigate to the project details page
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
                          ? const Text('No snags found.')
                          : LinearProgressIndicator(
                            value: _controller.getSnagProgress(),
                            color: Colors.blue,
                          ),

                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      // handle menu item selections
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'view',
                          child: Text('View Project')
                        ),
                        const PopupMenuItem<String>(
                          value: 'share',
                          child: Text('Share Project')
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Project')
                        ),
                        const PopupMenuDivider(height: 1.0),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete Project')
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
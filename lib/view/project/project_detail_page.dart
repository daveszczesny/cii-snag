import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';

class ProjectDetailPage extends StatefulWidget {
  final SingleProjectController projectController;
  const ProjectDetailPage({super.key, required this.projectController});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {

  @override
  Widget build(BuildContext context) {
    return Padding (
      padding: const EdgeInsets.all(38.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.projectController.getDescription != null) ...{
            buildTextDetail('Description', widget.projectController.getDescription!),
            const SizedBox(height: 28.0)
          }
        ],
      )
    );
  }

}
import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/view/utils/constants.dart';
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
          if (widget.projectController.getProjectId != null) ... {
            buildTextDetail(AppStrings.projectId, widget.projectController.getProjectId!),
            const SizedBox(height: 28.0)
          },
          if (widget.projectController.getDescription != null) ...{
            buildTextDetail(AppStrings.projectDescription, widget.projectController.getDescription!),
            const SizedBox(height: 28.0)
          },
          if (widget.projectController.getLocation != null) ... {
            buildTextDetail(AppStrings.projectLocation, widget.projectController.getLocation!),
            const SizedBox(height: 28.0)
          },
          if (widget.projectController.getClient != null) ... {
            buildTextDetail(AppStrings.projectClient, widget.projectController.getClient!),
            const SizedBox(height: 28.0)
          },
          if (widget.projectController.getContractor != null) ... {
            buildTextDetail(AppStrings.projectContractor, widget.projectController.getContractor!),
            const SizedBox(height: 28.0)
          },
          if (widget.projectController.getProjectRef != null) ... {
            buildTextDetail(AppStrings.projectRef, widget.projectController.getProjectRef!),
            const SizedBox(height: 28.0)
          }
        ],
      )
    );
  }

}
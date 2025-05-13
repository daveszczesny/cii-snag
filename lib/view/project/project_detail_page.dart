import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/selector.dart';
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding (
            padding: const EdgeInsets.all(38.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.projectController.getProjectId != '') ... {
                  buildTextDetail(AppStrings.projectId, widget.projectController.getProjectId!),
                  const SizedBox(height: 28.0)
                },
                if (widget.projectController.getDescription != '') ...{
                  buildTextDetail(AppStrings.projectDescription, widget.projectController.getDescription!),
                  const SizedBox(height: 28.0)
                },
                if (widget.projectController.getLocation != '') ... {
                  buildTextDetail(AppStrings.projectLocation, widget.projectController.getLocation!),
                  const SizedBox(height: 28.0)
                },
                if (widget.projectController.getClient != '') ... {
                  buildTextDetail(AppStrings.projectClient, widget.projectController.getClient!),
                  const SizedBox(height: 28.0)
                },
                if (widget.projectController.getContractor != '') ... {
                  buildTextDetail(AppStrings.projectContractor, widget.projectController.getContractor!),
                  const SizedBox(height: 28.0)
                },
                if (widget.projectController.getProjectRef != '') ... {
                  buildTextDetail(AppStrings.projectRef, widget.projectController.getProjectRef!),
                  const SizedBox(height: 28.0)
                },
                const SizedBox(height: 28.0),
                ObjectSelector(
                  label: 'Category',
                  pluralLabel: 'Categories',
                  hint: 'This allows you to create new categories to be used for snags in the project. Each snag can be assigned a single category',
                  options: widget.projectController.getCategories ?? [],
                  getName: (cat) => cat.name,
                  getColor: (cat) => cat.color,
                  onCreate: (name, color) {
                    setState(() {
                      widget.projectController.addCategory(name, color);
                    });
                  }
                ),
                const SizedBox(height: 28.0),
                ObjectSelector(
                  label: 'Tag',
                  pluralLabel: 'Tags',
                  hint: 'This allows you to create new tags to be used for snags in the project. Each snag can have multiple tags',
                  options: widget.projectController.getTags ?? [],
                  getName: (tag) => tag.name,
                  getColor: (tag) => tag.color,
                  onCreate: (name, color) {
                    setState(() {
                      widget.projectController.addTag(name, color);
                    });
                  }
                ),
              ],
            )
          )
        ]
      )
    );
  }

}
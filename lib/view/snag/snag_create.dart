import 'dart:io';

import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/category.dart' as cii;
import 'package:cii/models/priority.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/project/project_detail.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/image.dart';
import 'package:cii/view/utils/selector.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SnagCreate extends StatefulWidget {
  final SingleProjectController? projectController;

  const SnagCreate({super.key, this.projectController});

  @override
  State<SnagCreate> createState() => _SnagCreateState();
}

class _SnagCreateState extends State<SnagCreate> {

  final TextEditingController nameController = TextEditingController();
  // final TextEditingController priorityController = TextEditingController();
  final TextEditingController assigneeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  cii.Category? snagCategory;
  List<Tag>? snagTags = [];
  final List<String> priorityOptions = ['Low', 'Medium', 'High'];

  List<String> imageFilePaths = [];
  Map<String, String> annotatedImages = {};


  void createSnag() {
    final String name = nameController.text;
    final String assignee = assigneeController.text;
    final String location = locationController.text;
    final Priority priority = Priority.getPriorityByString(priorityController.text);

    if (widget.projectController != null) {
      widget.projectController?.addSnag(
        Snag(
          projectId: widget.projectController!.getProjectId ?? 'PID',
          name: name,
          location: location,
          assignee: assignee,
          categories: snagCategory != null ? [snagCategory!] : [],
          tags: snagTags,
          priority: priority,
          imagePaths: imageFilePaths,
          annotatedImagePaths: annotatedImages,
        )
      );

      Navigator.pop(context);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ProjectDetail(projectController: widget.projectController!))
      );
    }
  }  

  void onChange() {
    setState(() {});
  }

  void saveAnnotatedImage(String originalPath, String path) {
    setState(() {
      annotatedImages[originalPath] = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.projectController == null) {
      // Used via quick add
      return const Center(
        // TODO: Change later
        child: Text('No project selected'),
      );
    } else {
      return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(38.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextInput(AppStrings.snagName, AppStrings.snagNameExample, nameController),
                const SizedBox(height: 28.0),
                buildTextInput(AppStrings.projectLocation, 'Ex. Living Room', locationController),
                const SizedBox(height: 28.0),
                buildImageInput('Upload Image', context, imageFilePaths, onChange),
                const SizedBox(height: 14.0),
                if (imageFilePaths.isNotEmpty) ... [
                  buildImageShowcase(context, onChange, saveAnnotatedImage, imageFilePaths),
                  const SizedBox(height: 28.0),
                ],
                buildTextInput(AppStrings.assignee, AppStrings.assigneeExample, assigneeController),
                const SizedBox(height: 28.0),
                buildDropdownInput('Priority', priorityOptions, priorityController),
                const SizedBox(height: 28.0),
                ObjectSelector(
                  label: 'Category',
                  pluralLabel: 'Categories',
                  hint: 'This allows you to group snags into categories. Each snag can be assigned a single category',
                  options: widget.projectController?.getCategories ?? [],
                  getName: (cat) => cat.name,
                  getColor: (cat) => cat.color,
                  onCreate: (name, color) {
                    setState(() {
                      widget.projectController?.addCategory(name, color);
                    });
                  },
                  onSelect: (obj) {
                    setState(() {
                      if (snagCategory == obj) {
                        snagCategory = null;
                      } else {
                        snagCategory = obj;
                      }
                    });
                  },
                ),
                const SizedBox(height: 28.0),
                ObjectSelector(
                  label: 'Tag',
                  pluralLabel: 'Tags',
                  hint: 'This allows you to assign tags to snags. Each snag can be assigned multiple tags',
                  options: widget.projectController?.getTags ?? [],
                  getName: (tag) => tag.name,
                  getColor: (tag) => tag.color,
                  onCreate: (name, color) {
                    setState(() {
                      widget.projectController?.addTag(name, color);
                    });
                  },
                  onSelect: (obj) {
                    setState(() {
                      if (snagTags!.contains(obj)) {
                        snagTags?.remove(obj);
                      } else {
                        snagTags?.add(obj);
                      }
                    });
                  },
                  allowMultiple: true,
                ),
                const SizedBox(height: 28.0),
                ElevatedButton(
                  onPressed: createSnag,
                  child: const Text(AppStrings.snagCreate),
                )
              ],
            )
          )
        )
      );
    }
    
  }
}
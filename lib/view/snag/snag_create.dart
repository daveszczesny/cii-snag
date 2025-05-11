import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/view/project/project_detail.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';

class SnagCreate extends StatefulWidget {
  final SingleProjectController? projectController;

  const SnagCreate({super.key, this.projectController});

  @override
  State<SnagCreate> createState() => _SnagCreateState();
}

class _SnagCreateState extends State<SnagCreate> {

  final TextEditingController snagNameController = TextEditingController();

  void createSnag() {
    final String name = snagNameController.text;

    if (widget.projectController != null) {
      widget.projectController?.addSnag(
        Snag(
          projectId: widget.projectController!.getProjectId ?? 'PID',
          name: name
        )
      );

      Navigator.pop(context);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ProjectDetail(projectController: widget.projectController!))
      );
    }
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
                buildTextInput(AppStrings.snagName, AppStrings.snagNameExample, snagNameController),
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
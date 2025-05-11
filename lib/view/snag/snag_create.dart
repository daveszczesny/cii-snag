import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';

class SnagCreate extends StatefulWidget {
  final SingleProjectController? project;

  const SnagCreate({super.key, this.project});

  @override
  State<SnagCreate> createState() => _SnagCreateState();
}

class _SnagCreateState extends State<SnagCreate> {

  final TextEditingController snagNameController = TextEditingController();

  void createSnag() {
    final String name = snagNameController.text;

    if (widget.project != null) {
      widget.project?.addSnag(Snag(id: "123", name: name));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.project == null) {
      // Used via quick add
      return const Center(
        child: Text('No project selected'),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Snag'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // navigate back
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(38.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextInput('Snag name', 'Ex. Broken Light', snagNameController),
                const SizedBox(height: 28.0),
                ElevatedButton(
                  onPressed: createSnag,
                  child: const Text('Create Snag'),
                )
              ],
            )
          )
        )
      );
    }
    
  }
}
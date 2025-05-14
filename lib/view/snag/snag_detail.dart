import 'dart:io';

import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/controllers/snag_controller.dart';
import 'package:cii/models/status.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/image.dart';
import 'package:flutter/material.dart';

class SnagDetail extends StatefulWidget {
  final SingleProjectController projectController;
  final SnagController snag;
  final VoidCallback? onStatusChanged;

  const SnagDetail({super.key, required this.projectController, required this.snag, this.onStatusChanged});

  @override
  State<SnagDetail> createState() => _SnagDetailState();
}

class _SnagDetailState extends State<SnagDetail> {

  List<String> progressImageFilePaths = [];
  List<String> imageFilePaths = [];
  List<String> annotatedImageFilePaths = [];

  @override
  void initState() {
    super.initState();
  }

  void _showStatusModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: FractionallySizedBox(
            heightFactor: 0.7,
            child: Column(
              children: Status.values
              // .where((status) => status.name.toLowerCase() != 'completed')
              .map((status) {
                return ListTile(
                  title: Text(status.name),
                  onTap: () {
                    setState(() {
                      widget.snag.status = status;
                    });
                    widget.onStatusChanged!();
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            )
          )
        );
      },
    );
  }

  void _showCategoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      builder: (BuildContext context) {
        final categories = widget.projectController.getCategories!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: FractionallySizedBox(
            heightFactor: 0.7,
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return ListTile(
                  title: Text(cat.name),
                  onTap: () {
                    setState(() {
                      widget.snag.setCategory(cat);
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      }
    );
  }

  void onChangeSnagImage(){
    setState(() {
      bool reloadParent = false;
      if (widget.snag.imagePaths.isEmpty) {
        reloadParent = true;
      }

      widget.snag.imagePaths.addAll(imageFilePaths);
      if (reloadParent) {
        widget.onStatusChanged!();
      }
    });
  }

  void onChangeProgressImage() {
    setState(() {
      for (final path in progressImageFilePaths) {
        if (!widget.snag.progressImagePaths.contains(path)) {
          widget.snag.addProgressImagePath(path);
        }
      }
      progressImageFilePaths.clear();
      widget.projectController.saveProject();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.snag.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(38.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Page Contents
                  if (widget.snag.getId != '') ... [
                    Text('${AppStrings.id}: ${widget.snag.getId}'),
                    const SizedBox(height: 28.0)
                  ],
                  if (widget.snag.name != '') ...[
                    Text('${AppStrings.name}: ${widget.snag.name}'),
                    const SizedBox(height: 28.0)
                  ],

                  if (widget.snag.imagePaths != null && widget.snag.imagePaths!.isNotEmpty) ... [
                    const Text('Image'),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      height: 200,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: widget.snag.imagePaths!.length,
                        itemBuilder: (context, index) {
                          final imagePath = (widget.snag.annotatedImagePaths != null &&
                            widget.snag.annotatedImagePaths!.isNotEmpty &&
                            widget.snag.annotatedImagePaths!.containsKey(widget.snag.imagePaths![index]))
                            ? widget.snag.annotatedImagePaths![widget.snag.imagePaths![index]]!
                            : widget.snag.imagePaths![index];

                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: InteractiveViewer(child: Image.file(File(imagePath)))
                                  ),
                                )
                              );
                            },
                            child: Image.file(File(imagePath), fit: BoxFit.cover),
                          );
                        }
                      ),
                    )
                  ],

                  // add more snag images
                  buildImageInput('Add Snag Images', context, imageFilePaths, onChangeSnagImage),
                  

                  if (widget.snag.location != '') ... [
                    Text('${AppStrings.projectLocation}: ${widget.snag.location}'),
                    const SizedBox(height: 28.0)
                  ],

                  // Status
                  GestureDetector(
                    onTap: () => _showStatusModal(context),
                    child: Container(
                      width: 90,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Status.getStatus(widget.snag.status.name, context)!.color,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.snag.status.name,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Roboto',
                        )
                      )
                    )
                  ),

                  const SizedBox(height: 24.0),
                  // Progress Pictures (only if not completed)
                  if (widget.snag.status.name != Status.completed.name) ... [
                    buildImageInput(AppStrings.addProgressPictures, context, progressImageFilePaths, onChangeProgressImage)
                  ],

                  if (widget.snag.progressImagePaths.isNotEmpty) ... [
                    const Text(AppStrings.progressPictures),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      height: 200,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: widget.snag.progressImagePaths!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: InteractiveViewer(child: Image.file(File(widget.snag.progressImagePaths![index])))
                                  ),
                                )
                              );
                            },
                            child: Image.file(File(widget.snag.progressImagePaths![index]), fit: BoxFit.cover),
                          );
                        }
                      ),
                    )
                  ],

                  // Category and Tags
                  if (widget.snag.categories.isNotEmpty) ... [
                    const Text(AppStrings.category),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: widget.snag.categories.map((cat) {
                        return GestureDetector(
                          onTap: () => _showCategoryModal(context),
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 90,
                              maxWidth: 140,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: cat.color,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cat.name,
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Roboto',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          )
                        );
                    }).toList()),
                    const SizedBox(height: 28.0)
                  ],

                  if (widget.snag.tags.isNotEmpty) ... [
                    const Text(AppStrings.tags),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: widget.snag.tags.map((tag) {
                        return GestureDetector(
                          onTap: () => {},
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 90,
                              maxWidth: 140,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: tag.color,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              tag.name,
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Roboto',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          )
                        );
                    }).toList()),
                    const SizedBox(height: 28.0)
                  ],

                  if (widget.snag.assignee != '') ... [
                    Text('${AppStrings.assignee}: ${widget.snag.assignee}'),
                    const SizedBox(height: 28.0)
                  ],
                  if (widget.snag.finalRemarks != '') ... [
                    Text('${AppStrings.finalRemarks}: ${widget.snag.finalRemarks}'),
                    const SizedBox(height: 28.0)
                  ],
                ],
              ),
            )
          ]
        )
      ),
    );
  }
}
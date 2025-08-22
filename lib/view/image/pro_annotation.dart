import 'package:cii/view/image/custom_image_editor.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';

class ImageAnnotationScreen extends StatefulWidget {
  final String imagePath;

  const ImageAnnotationScreen({super.key, required this.imagePath});

  @override
  State<ImageAnnotationScreen> createState() => _ImageAnnotationScreenState();
}

class _ImageAnnotationScreenState extends State<ImageAnnotationScreen> {
  final GlobalKey _repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.imageAnnotation),
      ),
      body: CustomImageEditor(
        imagePath: widget.imagePath,
        onSave: (path) {
          Navigator.pop(context, path);
        },
      ),
    );
  }


}

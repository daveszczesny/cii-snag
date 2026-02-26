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
  bool _hasAnnotations = false;


  Future<bool> _showExitConfirmation() async {
    if (!_hasAnnotations) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Discard Changes?"),
        content: const Text("You have unsaved changes. Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Discard"),
          )
        ]
      )
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.imageAnnotation),
        ),
        body: CustomImageEditor(
          imagePath: widget.imagePath,
          onSave: (path) => Navigator.pop(context, path),
          onAnnotationChanged: (hasAnnotation) {
            setState(() => _hasAnnotations = hasAnnotation);
          },
        ),
      )
    );
  }


}

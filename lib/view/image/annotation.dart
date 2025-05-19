import 'dart:io';

import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';
import 'package:path_provider/path_provider.dart';

class ImageAnnotationScreen extends StatefulWidget {

  final String imagePath;

  const ImageAnnotationScreen({super.key, required this.imagePath});

  @override
  State<ImageAnnotationScreen> createState() => _ImageAnnotationScreenState();
}

class _ImageAnnotationScreenState extends State<ImageAnnotationScreen> {
  final imagePainterController = ImagePainterController(
    color: Colors.black,
    strokeWidth: 4,
    mode: PaintMode.line,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.imageAnnotation),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: saveImage,
          )
        ],
      ),
      body: ImagePainter.asset(
        widget.imagePath,
        controller: imagePainterController,
        scalable: true,
        textDelegate: TextDelegate(),
      )
    );
  }

   void saveImage() async {
  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  final image = await imagePainterController.exportImage();
  final imageName = '${DateTime.now().millisecondsSinceEpoch}.png';
  final directory = (await getApplicationDocumentsDirectory()).path;
  await Directory('$directory/snagImages').create(recursive: true);
  final fullPath = '$directory/snagImages/$imageName';
  final imgFile = File(fullPath);

  if (image != null) {
    imgFile.writeAsBytesSync(image);
    // Dismiss loading dialog
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.grey[700],
        padding: const EdgeInsets.only(left: 10),
        content: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Image saved',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
    Navigator.pop(context, fullPath);
  } else {
    // Dismiss loading dialog if something went wrong
    Navigator.of(context).pop();
  }
}

}
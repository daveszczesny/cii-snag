import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cii/view/image/custom_image_editor.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

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

  void saveImage() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      RenderRepaintBoundary boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      final directory = (await getApplicationDocumentsDirectory()).path;
      await Directory('$directory/snagImages').create(recursive: true);
      final imageName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final fullPath = '$directory/snagImages/$imageName';
      
      if (byteData != null) {
        await File(fullPath).writeAsBytes(byteData.buffer.asUint8List());
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.grey[700],
            content: const Text('Image saved', style: TextStyle(color: Colors.white)),
          ),
        );
        Navigator.pop(context, fullPath);
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

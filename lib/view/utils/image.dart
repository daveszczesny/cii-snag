import 'dart:io';

import 'package:cii/utils/common.dart';
import 'package:cii/view/image/annotation.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


Widget buildImageShowcase(BuildContext context, onChange, onSave, List<String> imageFilePaths) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: imageFilePaths.map((path) {
        return Stack(
          children: [
            // Main image tap (e.g., preview)
            GestureDetector(
              // same on tap behavior as edit button
              onTap: () async {
                final annotatedImagePath = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageAnnotationScreen(imagePath: path),
                    ),
                  );

                  if (annotatedImagePath != null) {
                    onSave(path, annotatedImagePath);
                  }
              },
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.file(File(path), fit: BoxFit.cover),
              ),
            ),
            // Delete button
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  imageFilePaths.remove(path);
                  onChange();
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
            // Edit button
            Positioned(
              bottom: 4,
              left: 4,
              child: GestureDetector(
                onTap: () async {
                  final annotatedImagePath = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageAnnotationScreen(imagePath: path),
                    ),
                  );

                  if (annotatedImagePath != null) {
                    onSave(path, annotatedImagePath);
                  }
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    ),
  );
}

Widget buildSingleImageShowcase(
  BuildContext context,
  String imageFilePath,
  VoidCallback onDelete,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Stack(
      children: [
        GestureDetector(
          onTap: () {
            // Show image full screen
            showDialog(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.transparent,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: InteractiveViewer(
                    child: Image.file(File(imageFilePath)),
                  ),
                ),
              ),
            );
          },
          child: SizedBox(
            width: 100,
            height: 100,
            child: Image.file(File(imageFilePath), fit: BoxFit.cover),
          ),
        ),
        // Delete button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    ),
  );
}


Widget buildSingleImageShowcaseBig(
  BuildContext context,
  String imageFilePath,
  VoidCallback onDelete,
) {
  final double width = MediaQuery.of(context).size.width * 0.9;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Stack(
      children: [
        GestureDetector(
          onTap: () {},
          child: SizedBox(
            width: width,
            height: width, // same as width for square
            child: Image.file(File(imageFilePath), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildImageInput(
  String label,
  BuildContext context,
  List<String> imageFilePaths,
  VoidCallback onChange,) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Roboto')),
      ),
      IconButton(
        icon: const Icon(Icons.upload, size: 28, color: Color(0xFF333333)),
        tooltip: 'Upload Images',
        onPressed: () => _showImagesSourceActionSheet(context, imageFilePaths, onChange),
      )
    ]
  );
}

Widget buildImageInputForSingleImage(
  String label,
  BuildContext context,
  void Function(String) onChange) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Roboto')),
      ),
      IconButton(
        icon: const Icon(Icons.upload, size: 28, color: Color(0xFF333333)),
        tooltip: 'Upload Images',
        onPressed: () => _showImageSourceActionSheet(context, onChange),
      )
    ]
  );
}


// Helper functions

// Single image
void _showImageSourceActionSheet(
  BuildContext context,
  void Function(String) onChange,
) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(AppStrings.photoLibrary),
              onTap: () {
                Navigator.of(context).pop();
                pickImageFromSource(onChange, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text(AppStrings.photoCamera),
              onTap: () {
                Navigator.of(context).pop();
                pickImageFromSource(onChange, ImageSource.camera);
              },
            )
          ]
        )
      );
    },
  );
}

// Multiple images
 void _showImagesSourceActionSheet(
  BuildContext context,
  List<String> imageFilePaths,
  VoidCallback onChange,
) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(AppStrings.photoLibrary),
              onTap: () {
                Navigator.of(context).pop();
                pickImagesFromSource(imageFilePaths, onChange, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text(AppStrings.photoCamera),
              onTap: () {
                Navigator.of(context).pop();
                pickImagesFromSource(imageFilePaths, onChange, ImageSource.camera);
              },
            )
          ]
        )
      );
    },
  );
}


Future<void> pickImageFromSource(
  void Function(String) onChange,
  ImageSource source
) async {
  final ImagePicker picker = ImagePicker();
  if (source == ImageSource.gallery) {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String imagePath = await saveImageToAppDir(File(image.path));
      onChange(imagePath);
    }
  } else {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      String imagePath = await saveImageToAppDir(File(image.path));
      onChange(imagePath);
    }
  }
}

Future<void> pickImagesFromSource(
  List<String> imageFilePaths,
  VoidCallback onChange,
  ImageSource source,
) async {
  final ImagePicker picker = ImagePicker();
  if (source == ImageSource.gallery) {
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      for (final image in images) {
        String imagePath = await saveImageToAppDir(File(image.path));
        imageFilePaths.add(imagePath);
      }
      onChange();
    }
  } else {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      String imagePath = await saveImageToAppDir(File(image.path));
      imageFilePaths.add(imagePath);
      onChange();
    }
  }
}
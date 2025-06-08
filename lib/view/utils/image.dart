import 'dart:io';

import 'package:cii/utils/common.dart';
import 'package:cii/view/image/annotation.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


Widget buildImageShowcase(BuildContext context, onChange, onSave, List<String> imageFilePaths, {double horizontalPadding = 48.0}) {

  final double screenWidth = MediaQuery.of(context).size.width;
  const double spacing = 8.0;
  const int imagesPerRow = 5;
  final double size = (screenWidth - horizontalPadding - (spacing * (imagesPerRow - 1))) / imagesPerRow;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: imageFilePaths.map((path) {

        if (path.isEmpty || File(path).existsSync() == false) {
          return const SizedBox.shrink();
        }
        return Stack(
          children: [
            // Main image tap (e.g., preview)
            GestureDetector(
              // same on tap behavior as edit button
              onTap: () async {
                onChange(p: path);
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Container(
                  height: size,
                  width: size,
                  color: Colors.grey[200],
                  child: Image.file(
                    File(path),
                    fit: BoxFit.cover,
                  ),
                ),
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
                  child: const Icon(Icons.close, color: Colors.red, size: 20),
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

Widget buildThumbnailImageShowcase(
  BuildContext context,
  String imageFilePath,
  {required Widget Function(BuildContext context) onDelete}
) {
  final double screenHeight = MediaQuery.of(context).size.height;
  final double height = screenHeight * 0.15;

  return Stack(
    children: [
      GestureDetector(
        onTap: () {
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
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: Container(
            height: height,
            width: double.infinity,
            color: Colors.grey[200],
            child: Image.file(
              File(imageFilePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      // Bin icon in the top right
      Positioned(
        top: 8,
        right: 8,
        child: GestureDetector(
          onTap: () {
            showDialog(context: context, builder: (ctx) => onDelete(ctx));
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.delete, color: Colors.white, size: 22),
          ),
        ),
      ),
    ],
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

// ignore: non_constant_identifier_names
Widget buildImageInput_V2(BuildContext context, void Function(String) onChange) {
  return Center(
    child: IconButton(
        icon: Image.asset(
          'lib/assets/icons/png/image_upload.png',
          width: 120,
          height: 120,
        ),
        tooltip: 'Upload Image',
        onPressed: () => _showImageSourceActionSheet(context, onChange),
      )
  );
}

// ignore: non_constant_identifier_names
Widget buildMultipleImageInput_V2(BuildContext context, List<String> imagePaths, VoidCallback onChange, {bool large = true}) {
  double width = 120;
  double height = 120;
  if (large) {
    width = 120;
    height = 120;
  } else {
    final double screenWidth = MediaQuery.of(context).size.width;
    width = (screenWidth - 48) / 6; 
    height = width;
  }

  return Center(
    child: IconButton(
      icon: Image.asset('lib/assets/icons/png/image_upload.png', width: width, height: height),
      tooltip: 'Upload Images',
      onPressed: () => _showImagesSourceActionSheet(context, imagePaths, onChange),
    )
  );
}

Widget showImageWithEditAbility(
  BuildContext context,
  String imageFilePath,
  onSave
) {
  if (imageFilePath.isEmpty || File(imageFilePath).existsSync() == false) {
    return const SizedBox.shrink();
  }
  
  final double screenHeight = MediaQuery.of(context).size.height;
  final double height = screenHeight * 0.3;

  return Stack(
    children: [
      GestureDetector(
        onTap: () {
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
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Container(
            height: height,
            width: double.infinity,
            color: Colors.grey[200],
            child: Image.file(
              File(imageFilePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      // Bin icon in the top right
      Positioned(
        top: 8,
        right: 8,
        child: GestureDetector(
          onTap: () async {
            final annotatedImagePath = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ImageAnnotationScreen(imagePath: imageFilePath)
              )
            );

            if (annotatedImagePath != null) onSave(imageFilePath, annotatedImagePath);
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.edit, color: Colors.white, size: 22),
          ),
        ),
      ),
    ],
  );
}


Widget showImageWithNoEditAbility(
  BuildContext context,
  String imageFilePath
) {
  if (imageFilePath.isEmpty || File(imageFilePath).existsSync() == false) {
    return const SizedBox.shrink();
  }
  
  final double screenHeight = MediaQuery.of(context).size.height;
  final double height = screenHeight * 0.3;

  return Stack(
    children: [
      GestureDetector(
        onTap: () {
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
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Container(
            height: height,
            width: double.infinity,
            color: Colors.grey[200],
            child: Image.file(
              File(imageFilePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ],
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
  const int maxImages = 5;
  if (source == ImageSource.gallery) {
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      // Calculate how many more images can be added
      int availableSlots = maxImages - imageFilePaths.length;
      if (availableSlots <= 0) return; // Already at max

      // Only add up to availableSlots images
      final imagesToAdd = images.take(availableSlots);
      for (final image in imagesToAdd) {
        String imagePath = await saveImageToAppDir(File(image.path));
        imageFilePaths.add(imagePath);
      }
      onChange();
    }
  } else {
    if (imageFilePaths.length >= maxImages) return; // Already at max
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      String imagePath = await saveImageToAppDir(File(image.path));
      imageFilePaths.add(imagePath);
      onChange();
    }
  }
}
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:cii/utils/common.dart';
import 'package:cii/view/image/pro_annotation.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class SimpleCropper extends StatefulWidget {
  final String imageFileName;

  const SimpleCropper({super.key, required this.imageFileName});
  @override
  State<SimpleCropper> createState() => _SimpleCropperState();
}

class _SimpleCropperState extends State<SimpleCropper> {
  double _offsetX = 0;
  double _offsetY = 0;
  late img.Image _image;
  late double _imageWidth;
  late double _imageHeight;
  late double _cropSize;
  bool _imageLoaded = false;
  double _initialScale = 1.0;
  double _baseSize = 0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final fullPath = await getImagePath(widget.imageFileName);
    final file = File(fullPath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image != null) {
      setState(() {
        _image = image;
        _imageWidth = image.width.toDouble();
        _imageHeight = image.height.toDouble();
        final minDimension = (_imageWidth < _imageHeight ? _imageWidth : _imageHeight);
        _cropSize = minDimension * 0.8; // Start at 80% of smaller dimension
        _offsetX = (_imageWidth - _cropSize) / 2;
        _offsetY = (_imageHeight - _cropSize) / 2;
        _imageLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Image"),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: () => _cropAndSave())
        ]
      ),
      body: _imageLoaded ? _buildCropInterface() : const Center(child: CircularProgressIndicator())
    );
  }

  Widget _buildCropInterface() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: FutureBuilder<String>(
                    future: getImagePath(widget.imageFileName),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      return Image.file(File(snapshot.data!), fit: BoxFit.contain);
                    }
                  )
                ),
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final displayWidth = constraints.maxWidth;
                      final displayHeight = constraints.maxHeight;
                      
                      final scaleX = displayWidth / _imageWidth;
                      final scaleY = displayHeight / _imageHeight;
                      final scale = scaleX < scaleY ? scaleX : scaleY;
                      
                      final scaledImageWidth = _imageWidth * scale;
                      final scaledImageHeight = _imageHeight * scale;
                      final scaledCropSize = _cropSize * scale;
                      
                      final imageLeft = (displayWidth - scaledImageWidth) / 2;
                      final imageTop = (displayHeight - scaledImageHeight) / 2;
                      
                      return Stack(
                        children: [
                          Container(
                            width: displayWidth,
                            height: displayHeight,
                            color: Colors.black54,
                          ),
                          Positioned(
                            left: imageLeft + (_offsetX * scale),
                            top: imageTop + (_offsetY * scale),
                            child: GestureDetector(
                              onScaleStart: (details) {
                                _initialScale = 1.0;
                                _baseSize = _cropSize;
                              },
                              onScaleUpdate: (details) {
                                setState(() {
                                  if (details.scale == 1.0) {
                                    // Handle movement
                                    final newOffsetX = _offsetX + (details.focalPointDelta.dx / scale);
                                    final newOffsetY = _offsetY + (details.focalPointDelta.dy / scale);
                                    
                                    _offsetX = newOffsetX.clamp(0, _imageWidth - _cropSize);
                                    _offsetY = newOffsetY.clamp(0, _imageHeight - _cropSize);
                                  } else {
                                    // Handle scaling with damping
                                    final scaleFactor = (details.scale - 1.0) * 0.5 + 1.0; // Damping factor
                                    final newSize = _baseSize * scaleFactor;
                                    final maxSize = (_imageWidth < _imageHeight ? _imageWidth : _imageHeight);
                                    final minSize = maxSize * 0.2;
                                    
                                    _cropSize = newSize.clamp(minSize, maxSize);
                                    
                                    _offsetX = _offsetX.clamp(0, _imageWidth - _cropSize);
                                    _offsetY = _offsetY.clamp(0, _imageHeight - _cropSize);
                                  }
                                });
                              },
                              child: Container(
                                width: scaledCropSize,
                                height: scaledCropSize,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Container(color: Colors.transparent),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text("Drag to move • Pinch to resize", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      ],
    );
  }

  Future<void> _cropAndSave() async {
    try {
      final cropped = img.copyCrop(
        _image, 
        x: _offsetX.round(),
        y: _offsetY.round(),
        width: _cropSize.round(),
        height: _cropSize.round()
      );

      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'cropped_$timestamp.png';
      final tempFile = File('${imagesDir.path}/$fileName');

      // Delete the original file to save memory
      final originalPath = await getImagePath(widget.imageFileName);
      final orginalFile = File(originalPath);
      if (await orginalFile.exists()) {
        await orginalFile.delete();
      }

      await tempFile.writeAsBytes(img.encodePng(cropped));

      Navigator.pop(context, fileName);
    } catch (e) {
      Navigator.pop(context, widget.imageFileName);
    }
  }
}

Future<bool> _checkAspectRatio(String imagePath) async {
  final fullPath = await getImagePath(imagePath);
  final file = File(fullPath);
  final bytes = await file.readAsBytes();
  final image = img.decodeImage(bytes);
  if (image == null || image.height == 0) return false;
  final aspectRatio = image.width / image.height;
  return aspectRatio >= 0.9 && aspectRatio <= 1.1;
}


Future<void> _showCropDialog(BuildContext context, String imagePath, Function(String) onChange) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("Crop Required"),
      content: const Text("This image has an unusual aspect ratio and must be cropped to continue."),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            final croppedPath = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (context) => SimpleCropper(imageFileName: imagePath),
              ),
            );
            onChange(croppedPath ?? imagePath);
          }, 
          child: const Text('Crop')
        )
      ]
    )
  );
}

Widget buildImageShowcase(BuildContext context, onChange, onSave, List<String> imageFilePaths,
  {double horizontalPadding = 48.0, Function(String)? onLongPress}) {

  final double screenWidth = MediaQuery.of(context).size.width;
  const double spacing = 8.0;
  const int imagesPerRow = 5;
  final double size = (screenWidth - horizontalPadding - (spacing * (imagesPerRow - 1))) / imagesPerRow;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: imageFilePaths.map((fileName) {
        return FutureBuilder<String>(
          future: generateThumnbnail(fileName),
          builder: (context, snapshot) {
            if (!snapshot.hasData || fileName.isEmpty) {
              return const SizedBox.shrink();
            }
            final fullPath = snapshot.data!;

            return Stack(
              children: [
                // Main image tap (e.g., preview)
                GestureDetector(
                  // same on tap behavior as edit button
                  onTap: () async {
                    onChange(p: fileName);
                  },
                  onLongPress: () {
                    if (onLongPress == null) return;
                    showModalBottomSheet(context: context,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.star),
                              title: const Text('Set as Main Image'),
                              onTap: () {
                                Navigator.pop(context);
                                onLongPress(fileName);
                              }
                            )
                          ],
                        )
                      )
                    );
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: Container(
                      height: size,
                      width: size,
                      color: Colors.grey[200],
                      child: Image.file(
                        File(fullPath),
                        fit: BoxFit.cover,
                        cacheWidth: 200,
                        cacheHeight: 200,
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
                      // remove from the UI
                      imageFilePaths.remove(fileName);
                      onChange();

                      /* Clean up images */
                      getImagePath(fileName).then((fullPath) {
                        final file = File(fullPath);
                        if (file.existsSync()) file.delete();
                      });

                      getThumbnailPath(fileName).then((thumbPath) {
                        if (thumbPath != null) {
                          final thumbFile = File(thumbPath);
                          if (thumbFile.existsSync()) thumbFile.delete();
                        }
                      });

                      // TODO - verify that annotated images are also cleaned up
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
          });
      }).toList(),
    ),
  );
}

Widget buildSingleImageShowcase(
  BuildContext context,
  String imageFileName,
  VoidCallback onDelete,
) {
  return FutureBuilder<String>(
    future: getImagePath(imageFileName),
    builder: (context, snapshot) {
      if (!snapshot.hasData || imageFileName.isEmpty) {
        return const SizedBox.shrink();
      }

      final imageFilePath = snapshot.data!;
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
  );
}

Widget buildThumbnailImageShowcase(
  BuildContext context,
  String imageFileName,
  {required Widget Function(BuildContext context) onDelete}
) {
  
  return FutureBuilder<String>(
    future: getImagePath(imageFileName),
    builder: (context, snapshot) {
      if (!snapshot.hasData || imageFileName.isEmpty) {
        return const SizedBox.shrink();
      }

      final imageFilePath = snapshot.data!;
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
  );

}

Widget buildSingleImageShowcaseBig(
  BuildContext context,
  String imageFileName,
  VoidCallback onDelete,
) {
  return FutureBuilder<String>(
    future: getImagePath(imageFileName),
    builder: (context, snapshot) {
      if (!snapshot.hasData || imageFileName.isEmpty) {
        return const SizedBox.shrink();
      }

      final imageFilePath = snapshot.data!;
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

Widget buildImageInput_V3(
  BuildContext context,
  VoidCallback onChange,
  List<String> imageFilePaths,
  {bool large = true,
  horizontalPadding = 48.0}
  ) {
  double width = 120;
  double height = 120;
  if (large) {
    width = 120;
    height = 120;
  } else {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double spacing = 8.0;
    const int imagesPerRow = 5;
    final double size = (screenWidth - horizontalPadding - (spacing * (imagesPerRow - 1))) / imagesPerRow;
    width = size * 0.8;
    height = size * 0.8;
  }

  return Center(
    child: IconButton(
      icon: Image.asset('lib/assets/icons/png/image_upload.png', width: width, height: height),
      tooltip: "Upload Images",
      onPressed: () => _showImagesSourceActionSheet(context, imageFilePaths, onChange)
    )
  );
}

// ignore: non_constant_identifier_names
Widget buildImageInput_V2(BuildContext context, void Function(String) onChange, {bool ignoreAspectRatio = false}) {
  return Center(
    child: IconButton(
        icon: Image.asset(
          'lib/assets/icons/png/image_upload.png',
          width: 120,
          height: 120,
        ),
        tooltip: 'Upload Image',
        onPressed: () => _showImageSourceActionSheet(context, onChange, ignoreAspectRatio:ignoreAspectRatio),
      )
  );
}

// ignore: non_constant_identifier_names
Widget buildMultipleImageInput_V2(BuildContext context, List<String> imagePaths, VoidCallback onChange,
  {bool large = true,
   horizontalPadding = 48.0}) {
  double width = 120;
  double height = 120;
  if (large) {
    width = 120;
    height = 120;
  } else {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double spacing = 8.0;
    const int imagesPerRow = 5;
    final double size = (screenWidth - horizontalPadding - (spacing * (imagesPerRow - 1))) / imagesPerRow;
    width = size * 0.8;
    height = size *0.8;
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
  String imageFileName,
  onSave
) {

  return FutureBuilder<String>(
    future: getImagePath(imageFileName),
    builder: (context, snapshot) {
      if (!snapshot.hasData){
        return const SizedBox.shrink();
      }

      final imageFilePath = snapshot.data!;
      final double screenHeight = MediaQuery.of(context).size.height;
      final double maxHeight = screenHeight * 0.4;

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
            constraints: BoxConstraints(
              maxHeight: maxHeight,
              minHeight: 200, // Minimum height to ensure visibility
            ),
            width: double.infinity,
            color: Colors.grey[200],
            child: Image.file(
              File(imageFilePath),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
      // Edit icon in the top right
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

            if (annotatedImagePath != null) onSave(imageFileName, annotatedImagePath);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.edit, color: Colors.white, size: 20),
          ),
        ),
      ),
    ],
  );
    }
  );
}


Widget showImageWithNoEditAbility(
  BuildContext context,
  String imageFileName
) {

  return FutureBuilder<String>(
    future: getImagePath(imageFileName),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const SizedBox.shrink();
      }

      final imageFilePath = snapshot.data!;
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
  );

  

}

// Helper functions

// Single image
void _showImageSourceActionSheet(
  BuildContext context,
  void Function(String) onChange,
  {bool ignoreAspectRatio = false}
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
                pickImageFromSource(onChange, ImageSource.gallery, context, ignoreAspectRatio: ignoreAspectRatio);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text(AppStrings.photoCamera),
              onTap: () {
                Navigator.of(context).pop();
                pickImageFromSource(onChange, ImageSource.camera, context, ignoreAspectRatio: ignoreAspectRatio);
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
                pickImageFromSource((String path) {
                  if (imageFilePaths.length < 5) {
                    imageFilePaths.add(path);
                    onChange();
                  }
                }, ImageSource.gallery, context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text(AppStrings.photoCamera),
              onTap: () {
                Navigator.of(context).pop();
                pickImageFromSource((String path) {
                  if (imageFilePaths.length < 5) {
                    imageFilePaths.add(path);
                    onChange();
                  }
                }, ImageSource.camera, context);
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
  ImageSource source,
  BuildContext context,
  {bool ignoreAspectRatio = false}
) async {

  await AppImageSettings.loadImageSettingsPrefs();

  final bool saveToGallery = AppImageSettings.saveToGallery;
  
  final ImagePicker picker = ImagePicker();
  XFile? image;
  final rootContext = Navigator.of(context, rootNavigator: true).context;

  if (source == ImageSource.gallery) {
    image = await picker.pickImage(source: ImageSource.gallery);
  } else {
    image = await picker.pickImage(source: ImageSource.camera);
  }

  if (image != null) {
    if (rootContext.mounted) {
      showDialog(
        context: rootContext,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    if (saveToGallery && source == ImageSource.camera) {
      await Gal.putImage(image.path);
    }
    String imagePath = await compressAndSaveImage(File(image.path));

    if(rootContext.mounted) Navigator.of(rootContext).pop();
    var hasGoodAspectRatio = await _checkAspectRatio(imagePath);
    if (ignoreAspectRatio) {
      hasGoodAspectRatio = true;
    }

    if (!hasGoodAspectRatio) {
      if (rootContext.mounted) {
        // navigate to cropping tool
        final croppedPath = await Navigator.push<String>(rootContext,
          MaterialPageRoute(builder: (context) => SimpleCropper(imageFileName: imagePath)
        ));
        onChange(croppedPath!);
      } else {
        onChange(imagePath);
      }
    } else {
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
        String imagePath = await compressAndSaveImage(File(image.path));
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
import 'dart:io';

import 'package:cii/models/project.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

// to save an image
Future<void> saveImage(Project project) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = pickedFile.name;
    final savedImagePath = '${appDir.path}/$fileName';

    final imageFile = File(pickedFile.path);
    await imageFile.copy(savedImagePath);
  }
}
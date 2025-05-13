import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<String> saveImageToAppDir(File imageFile) async {
  final appDir = await getApplicationDocumentsDirectory();
  final fileName = path.basename(imageFile.path);
  final savedImage = await imageFile.copy('${appDir.path}/$fileName');
  return savedImage.path;
}

String capitilize(String s){
  return s[0].toUpperCase() + s.substring(1);
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

DateTime? parseDate(String date) {
  if (date.isEmpty) return null;
  
  DateTime? parsedDate;

  try {
    // Try dd.MM.yyyy
    if (RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(date)) {
      parsedDate = DateFormat('dd.MM.yyyy').parseStrict(date);
    }
    // Try dd-MM-yyyy
    else if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(date)) {
      parsedDate = DateFormat('dd-MM-yyyy').parseStrict(date);
    }
    // Fallback to ISO or throw
    else {
      parsedDate = DateTime.parse(date);
    }

    return parsedDate;
  } catch (e) {
    return null;
  }
}
import 'dart:io';
import 'package:cii/models/snag.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:cii/providers/providers.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/image.dart';
import 'package:cii/view/utils/text.dart';
import 'package:cii/models/status.dart';

Future<String> saveImageToAppDir(File imageFile) async {
  final appDir = await getApplicationDocumentsDirectory();

  final imagesDir = Directory('${appDir.path}/images');
  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }

  final fileName = path.basename(imageFile.path);
  await imageFile.copy('${imagesDir.path}/$fileName');

  return fileName;
}

Future<String> getImagePath(String fileName) async {
  final appDir = await getApplicationDocumentsDirectory();
  return '${appDir.path}/images/$fileName';
}

String capitilize(String s){
  return s[0].toUpperCase() + s.substring(1);
}

DateTime? parseDate(String date) {
  if (date.isEmpty) return null;

  DateTime? parsedDate;
  final pattern = AppDateTimeFormat.dateTimeFormatPattern;

  try {
    // Try the user-selected format first
    try {
      parsedDate = DateFormat(pattern).parseStrict(date);
      return parsedDate;
    } catch (_) {}

    // Try dd.MM.yyyy
    if (RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(date)) {
      parsedDate = DateFormat('dd.MM.yyyy').parseStrict(date);
    }
    // Try dd-MM-yyyy
    else if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(date)) {
      parsedDate = DateFormat('dd-MM-yyyy').parseStrict(date);
    }
    // Try dd/MM/yyyy
    else if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(date)) {
      parsedDate = DateFormat('dd/MM/yyyy').parseStrict(date);
    }
    // Try MM/dd/yyyy
    else if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(date)) {
      parsedDate = DateFormat('MM/dd/yyyy').parseStrict(date);
    }
    // Try yyyy/MM/dd
    else if (RegExp(r'^\d{4}/\d{2}/\d{2}$').hasMatch(date)) {
      parsedDate = DateFormat('yyyy/MM/dd').parseStrict(date);
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

// format datetime to String in user preferrred format
String formatDate(DateTime date) {
  final pattern = AppDateTimeFormat.dateTimeFormatPattern;
  return DateFormat(pattern).format(date);
}

Future<void> buildFinalRemarksWidget(
  BuildContext parentContext, 
  Snag snag,
  Function onChange,
  List<String> finalImagePaths,
  WidgetRef ref,
  {double width = 0, double height = 0}) async{
  return await showDialog(
    context: parentContext,
    barrierDismissible: false,
    builder: (context) {
      final TextEditingController remarksController = TextEditingController();
      final TextEditingController reviewedByController = TextEditingController();
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: width,
                minHeight: height,
                maxHeight: height, // Adjust as needed
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Closing Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    if (finalImagePaths.isEmpty) ... [
                      buildMultipleImageInput_V2(context, finalImagePaths, () {
                        setState((){});
                      })
                    ] else ... [
                      showImageWithNoEditAbility(context, finalImagePaths[0])
                    ],
                    const SizedBox(height: 14),
                    if (finalImagePaths.isNotEmpty) ... [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildImageShowcase(
                            context,
                            ({String p = ''}) {setState(() {});},
                            () {},
                            finalImagePaths,
                            horizontalPadding: 48.0 + 32.0
                          ),
                          if (finalImagePaths.length < 5) ... [
                            buildMultipleImageInput_V2(context, finalImagePaths, () {
                              setState(() {});
                            }, large: false, horizontalPadding: 48.0 + 32.0)
                          ]
                        ],
                      )
                    ],

                    const SizedBox(height: 16),
                    buildLongTextInput("Final Remarks", "E.g. ${AppStrings.snag()} complete", remarksController),
                    const SizedBox(height: 16),
                    buildLongTextInput("Reviewed By", "E.g. John Doe", reviewedByController),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(AppStrings.cancel),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final updatedSnag = snag.copyWith(
                              finalRemarks: remarksController.text,
                              reviewedBy: reviewedByController.text,
                              finalImagePaths: finalImagePaths,
                              status: Status.completed
                            );
                            ref.read(snagProvider.notifier).updateSnag(updatedSnag);
                            onChange();
                            Navigator.pop(context);
                          },
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  ],
                ),
                )
              ),
            ),
          );
        }
      );
    },
  );
}

String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

Future<String> getPdfDirectory() async {
  final appDir = await getApplicationDocumentsDirectory();
  final pdfDir = Directory('${appDir.path}/pdf_exports');
  if (!await pdfDir.exists()) {
    await pdfDir.create();
  }
  return pdfDir.path;
}

Future<String> getCsvDirectory() async {
  final appDir = await getApplicationDocumentsDirectory();
  final csvDir = Directory('${appDir.path}/csv_exports');
  if (!await csvDir.exists()) {
    await csvDir.create();
  }
  return csvDir.path;
}


bool isNullorEmpty(String? s) {
  return s == null || s.isEmpty;
}

bool isListNullorEmpty(List? l) {
  return l == null || l.isEmpty;
}
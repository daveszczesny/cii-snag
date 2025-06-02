import 'dart:io';
import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/controllers/snag_controller.dart';
import 'package:cii/models/status.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/image.dart';
import 'package:cii/view/utils/text.dart';
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
  SnagController snagController,
  SingleProjectController projectController,
  Function onChange,
  List<String> finalImagePaths,
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
                    const Text('Completion Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
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
                            finalImagePaths
                          ),
                          if (finalImagePaths.length < 5) ... [
                            buildMultipleImageInput_V2(context, finalImagePaths, () {
                              setState(() {});
                            }, large: false)
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
                            snagController.setFinalRemarks(remarksController.text);
                            snagController.setReviewedBy(reviewedByController.text);
                            snagController.setFinalImagePaths(finalImagePaths);
                            snagController.status = Status.completed;
                            projectController.updateSnag(snagController.snag);
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
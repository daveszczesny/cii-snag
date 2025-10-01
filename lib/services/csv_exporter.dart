

import 'dart:convert';
import 'dart:io';

import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/controllers/snag_controller.dart';
import 'package:cii/models/csvexportrecords.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:crypto/crypto.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/*

CSV Exporter

This will export the project data to a CSV file.

The SaveCsvFile function will do the following
- Take project main details
- Take project issues details (no images)
- Export to CSV file
  */

Future<void> saveCsvFile(
  BuildContext context,
  SingleProjectController projectController,
) async {

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator())
  );

  List<List<dynamic>> csvData = [];

  final projectDetails = getProjectDetails(projectController);
  final snagList = getSnagList(projectController);

  projectDetails.forEach((k, v) {
    csvData.add([k, v]);
  });

  csvData.add(['']);
  csvData.add([
    "ID",
    "Name",
    "Created",
    "Due Date",
    "Date Completed",
    "Priority",
    "Status",
    "Location",
    "Assignee",
    "Category",
    "Description",
  ]);

  for (int i = 0; i < snagList.length; i++) {
    final snag = snagList[i];
    csvData.add([
      snag["ID"],
      snag["Name"],
      snag["Created"],
      snag["Due Date"],
      snag["Date Completed"],
      snag["Priority"],
      snag["Status"],
      snag["Location"],
      snag["Assignee"],
      snag["Category"],
      snag["Description"]
    ]);
    if (i < snagList.length - 1) {
      csvData.add(['']);
    }
  }

  String csv = const ListToCsvConverter().convert(csvData);

  final bytes = utf8.encode(csv);
  final csvDirPath = await getCsvDirectory();
  final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final fileName = '${projectController.getName}_export_$timestamp.csv';
  final file = File('$csvDirPath/$fileName');
  await file.writeAsString(csv);

  final csvRecord = CsvExportRecords(
    exportDate: DateTime.now(),
    fileName: fileName,
    fileHash: sha256.convert(bytes).toString(),
    fileSize: bytes.length,
  );

  projectController.addCsvExportRecord(csvRecord);
  await Share.shareXFiles([XFile(file.path)]);
  Navigator.of(context).pop(); // Remove loading indicator

}

// Get project details
Map<String, String> getProjectDetails(SingleProjectController controller) {
  return {
    'Project Name': controller.getName ?? '-',
    'Client': controller.getClient == "" ? '-' : controller.getClient!,
    'Location': controller.getLocation == "" ? '-' : controller.getLocation!,
    'Reference': controller.getProjectRef!,
    'Status': controller.getStatus!,
  };
}

// get list of snags and their details
List<Map<String, String>> getSnagList(SingleProjectController controller) {
  final snags = controller.getAllSnags();
  
  return snags.map((SnagController snag) {
    return {
      "ID": snag.getId,
      "Name": snag.name,
      "Created": DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(snag.dateCreated),
      "Due Date": snag.getDueDate != null ? snag.getDueDateString! : "-",
      "Date Completed": snag.dateCompleted != null ? DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(snag.dateCompleted!) : '-',
      "Priority": snag.priority.name,
      "Status": snag.status.name,
      "Location": snag.location == "" ? '-' : snag.location,
      "Assignee": snag.assignee == "" ? '-' : snag.assignee,
      "Category": snag.categories.isNotEmpty ? snag.categories[0].name : "-",
      "Description": snag.description == "" ? '-' : snag.description,
    };
  }).toList();
}

Future<void> openCsvFromRecord(CsvExportRecords record) async {
  final csvDirPath = await getCsvDirectory();
  final filePath = '$csvDirPath/${record.fileName}';
  final file = File(filePath);
  if (await file.exists()) {
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      throw Exception("Could not open CSV: ${result.message}");
    }
  } else {
    throw FileSystemException("File not found", filePath);
  }
}
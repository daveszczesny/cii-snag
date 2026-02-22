

import 'dart:convert';
import 'dart:io';

import 'package:cii/models/csvexportrecords.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/services/tier_service.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:crypto/crypto.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
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
  String projectId,
  WidgetRef ref,
  String csvFileName,
) async {

  TierService.instance.checkCsvExport();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator())
  );

  List<List<dynamic>> csvData = [];

  final Project project = ProjectService.getProject(ref, projectId);
  final Map<String, String> projectDetails = getProjectDetails(project);
  final List<Map<String, String>> snagList = getSnagList(projectId, ref);

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
  // final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final fileName = "$csvFileName.csv";
  final file = File('$csvDirPath/$fileName');
  await file.writeAsString(csv);

  final csvRecord = CsvExportRecords(
    exportDate: DateTime.now(),
    fileName: fileName,
    fileHash: sha256.convert(bytes).toString(),
    fileSize: bytes.length,
  );

  final updatedProject = project.copyWith(
    csvExportRecords: [...(project.csvExportRecords ?? []), csvRecord]
  );
  ProjectService.updateProject(ref, updatedProject);
  await SharePlus.instance.share(ShareParams(
    files: [XFile(file.path)],
    sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100)
  ));
  Navigator.of(context).pop(); // Remove loading indicator

}

// Get project details
Map<String, String> getProjectDetails(Project project) {
  return {
    'Project Name': project.name,
    'Client': isNullorEmpty(project.client) ? '-' : project.client!,
    'Location': isNullorEmpty(project.location) ? '-' : project.location!,
    'Reference': project.projectRef!,
    'Status': project.status.name,
  };
}

// get list of snags and their details
List<Map<String, String>> getSnagList(String projectId, WidgetRef ref) {
  final List<Snag> snags = ProjectService.getSnags(ref, projectId);

  return snags.map((Snag snag) {
    return {
      "ID": snag.id,
      "Name": snag.name,
      "Created": snag.dateClosed != null ? DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(snag.dateCreated) : "-",
      "Due Date": snag.dueDate != null ? DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(snag.dueDate!) : "-",
      "Date Completed": snag.dateCompleted != null ? DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(snag.dateCompleted!) : '-',
      "Priority": snag.priority.name,
      "Status": snag.status.name,
      "Location": isNullorEmpty(snag.location) ? '-' : snag.location!,
      "Assignee": isNullorEmpty(snag.assignee) ? '-' : snag.assignee!,
      "Category": (snag.categories != null && snag.categories!.isNotEmpty) ? snag.categories![0].name : "-",
      "Description": isNullorEmpty(snag.description) ? '-' : snag.description!,
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

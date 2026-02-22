
import 'package:cii/models/project.dart';
import 'package:cii/services/csv_exporter.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/view/project/export/project_export_customizer_base.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ProjectCsvExportCustomizer extends ProjectExportCustomizerBase {
  const ProjectCsvExportCustomizer({super.key, required super.projectId});

  @override
  ConsumerState<ProjectCsvExportCustomizer> createState() => _ProjectCsvExportCustomizerState();
}

class _ProjectCsvExportCustomizerState extends ProjectExportCustomizerBaseState<ProjectCsvExportCustomizer> {

  @override
  String get title => "CSV Export Customization";

  final TextEditingController nameController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Project project = ProjectService.getProject(ref, widget.projectId);
    nameController.text = buildDefaultCsvFileName(project.projectRef!);
  }

  @override
  List<Widget> buildCustomOptions({Project? project}) {
    String fileNameHint = project != null ? buildDefaultCsvFileName(project.projectRef!) : "File Name";
    return [
      buildLimitedTextInput("File Name", fileNameHint, nameController, 50),
      const SizedBox(height: 24.0),
    ];
  }

  @override
  Widget buildExportButton() {
  
    return buildTextButton(
      "Export to CSV",
      () async {
        saveCsvFile(context, widget.projectId, ref, nameController.text);
        Navigator.pop(context);
      }
    );
  }


  String buildDefaultCsvFileName(String ref) {
    // timestamp yyMMdd_hhMMss
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return "${ref}_$timestamp";
  }
}
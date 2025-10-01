
import 'package:cii/services/csv_exporter.dart';
import 'package:cii/view/project/export/project_export_customizer_base.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';

class ProjectCsvExportCustomizer extends ProjectExportCustomizerBase {
  const ProjectCsvExportCustomizer({super.key, required super.projectController});

  @override
  State<ProjectCsvExportCustomizer> createState() => _ProjectCsvExportCustomizerState();
}

class _ProjectCsvExportCustomizerState extends ProjectExportCustomizerBaseState<ProjectCsvExportCustomizer> {

  @override
  String get title => "CSV Export Customization";

  @override
  List<Widget> buildCustomOptions() {
    return [];
  }

  @override
  Widget buildExportButton() {
  
    return buildTextButton(
      "Export to CSV",
      () async {
        saveCsvFile(context, widget.projectController);
        Navigator.pop(context);
      }
    );
  }
}
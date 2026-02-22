
import 'package:cii/models/project.dart';
import 'package:cii/services/csv_exporter.dart';
import 'package:cii/view/project/export/project_export_customizer_base.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectCsvExportCustomizer extends ProjectExportCustomizerBase {
  const ProjectCsvExportCustomizer({super.key, required super.projectId});

  @override
  ConsumerState<ProjectCsvExportCustomizer> createState() => _ProjectCsvExportCustomizerState();
}

class _ProjectCsvExportCustomizerState extends ProjectExportCustomizerBaseState<ProjectCsvExportCustomizer> {

  @override
  String get title => "CSV Export Customization";

  @override
  List<Widget> buildCustomOptions({Project? project}) {
    return [];
  }

  @override
  Widget buildExportButton() {
  
    return buildTextButton(
      "Export to CSV",
      () async {
        saveCsvFile(context, widget.projectId, ref);
        Navigator.pop(context);
      }
    );
  }
}
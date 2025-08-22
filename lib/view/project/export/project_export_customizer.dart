
import 'package:cii/services/pdf_exporter.dart';
import 'package:cii/view/project/export/project_export_customizer_base.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cii/utils/pdf/themes.dart';

class ProjectExportCustomizer extends ProjectExportCustomizerBase {
  const ProjectExportCustomizer({super.key, required super.projectController});

  @override
  State<ProjectExportCustomizer> createState() => _ProjectExportCustomizerState();
}

class _ProjectExportCustomizerState extends ProjectExportCustomizerBaseState<ProjectExportCustomizer> {

  late ValueNotifier<String> selectedQualityNotifier;


  final Map<String, dynamic> options = {
    "Standard I": buildSnagPage_theme1,
    "Standard II": buildSnagPage_theme1,
  };
  final TextEditingController themeController = TextEditingController();


  @override
  void initState() {
    super.initState();
    selectedQualityNotifier = ValueNotifier<String>('High');
    themeController.text = options.keys.first;
  }

  @override
  String get title => "PDF Export Customization";

  @override
  List<Widget> buildCustomOptions() {
    return [
      buildCustomSegmentedControl(
        label: "Photo Quality",
        options: ["Low", "Medium", "High"],
        selectedNotifier: selectedQualityNotifier
      ),
      const SizedBox(height: 24.0),

      buildDropdownInput("Theme", options.keys.toList(), themeController), // theme controller
      const SizedBox(height: 24.0)

    ];
  }

  @override
  Widget buildExportButton() {
    return buildTextButton(
      "Export to PDF",
      () async {
        await savePdfFile(
          context,
          widget.projectController,
          selectedQualityNotifier.value,
          options[themeController.text],
          selectedCategories.toList(),
          selectedStatuses.toList(),
        );
        Navigator.of(context).pop();
      }
    );
  }
}
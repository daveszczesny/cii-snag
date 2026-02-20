import 'package:cii/services/pdf_exporter.dart';
import 'package:cii/services/tier_service.dart';
import 'package:cii/view/project/export/project_export_customizer_base.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:cii/utils/pdf/themes.dart';
import 'package:intl/intl.dart';

class ProjectExportCustomizer extends ProjectExportCustomizerBase {
  const ProjectExportCustomizer({super.key, required super.projectController});

  @override
  State<ProjectExportCustomizer> createState() => _ProjectExportCustomizerState();
}

class _ProjectExportCustomizerState extends ProjectExportCustomizerBaseState<ProjectExportCustomizer> {

  late ValueNotifier<String> selectedQualityNotifier;


  final Map<String, dynamic> options = {
    "Standard I": buildSnagPage_theme1,
    // "Standard II": buildSnagPage_theme1,
  };
  final TextEditingController themeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    selectedQualityNotifier = ValueNotifier<String>('Low');
    themeController.text = options.keys.first;
    nameController.text = buildDefaultPdfFileName();
  }

  @override
  String get title => "PDF Export Customization";

  @override
  List<Widget> buildCustomOptions() {
    String fileNameHint = buildDefaultPdfFileName();
    return [
      buildTextInput("File Name", fileNameHint, nameController),

      const SizedBox(height: 24.0),

      buildCustomSegmentedControl(
        label: TierService.instance.canPdfQualityChange ? "Image Quality" : "Image Quality (Upgrade to Premium to unlock)",
        options: ["Low", "Medium", "High"],
        selectedNotifier: selectedQualityNotifier,
        enabled: TierService.instance.canPdfQualityChange
      ),
      const SizedBox(height: 24.0),

      buildDropdownInput(
        "Theme",
        options.keys.toList(), themeController, enabled: TierService.instance.canPdfThemeChange),
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
          nameController.text,
          selectedCategories.toList(),
          selectedStatuses.toList(),
        );

        if (mounted) { // TODO verify if this works?
          Navigator.of(context).pop();
        }
      }
    );
  }


  String buildDefaultPdfFileName() {
    // timestamp yyMMdd_hhMMss
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    String ref = widget.projectController.getProjectRef;
    return "${ref}_$timestamp";
  }
}

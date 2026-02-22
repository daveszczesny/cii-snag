import 'package:cii/services/pdf_exporter.dart';
import 'package:cii/services/tier_service.dart';
import 'package:cii/view/project/export/project_export_customizer_base.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:cii/utils/pdf/themes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectExportCustomizer extends ProjectExportCustomizerBase {
  const ProjectExportCustomizer({super.key, required super.projectId});

  @override
  ConsumerState<ProjectExportCustomizer> createState() => _ProjectExportCustomizerState();
}

class _ProjectExportCustomizerState extends ProjectExportCustomizerBaseState<ProjectExportCustomizer> {

  late ValueNotifier<String> selectedQualityNotifier;


  final Map<String, dynamic> options = {
    "Standard I": buildSnagPage_theme1,
    // "Standard II": buildSnagPage_theme1,
  };
  final TextEditingController themeController = TextEditingController();


  @override
  void initState() {
    super.initState();
    selectedQualityNotifier = ValueNotifier<String>('Low');
    themeController.text = options.keys.first;
  }

  @override
  String get title => "PDF Export Customization";

  @override
  List<Widget> buildCustomOptions() {
    return [
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
          widget.projectId,
          selectedQualityNotifier.value,
          options[themeController.text],
          ref,
          selectedCategories.toList(),
          selectedStatuses.toList(),
        );
        Navigator.of(context).pop();
      }
    );
  }
}
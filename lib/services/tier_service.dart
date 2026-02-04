import 'package:cii/models/tier_limits.dart';
import 'package:cii/services/premium_service.dart';
import 'package:cii/controllers/project_controller.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:path/path.dart';

class TierLimitException implements Exception {
  final String message;
  final String feature;

  TierLimitException(this.feature, this.message);

  @override
  String toString() => message;
}

class TierService {
  static TierService? _instance;
  static TierService get instance => _instance ??= TierService._();
  TierService._();

  TierLimits get currentLimits => PremiumService.instance.isPremium ? TierLimits.pro : TierLimits.free;

  // Project limits
  bool canCreateProject(ProjectController projectController) {
    final limits = currentLimits;
    if (limits.maxProjects == -1) return true;
    return projectController.getAllProjects().length < limits.maxProjects;
  }

  void canProjectLimit(ProjectController projectController) {
    if (!canCreateProject(projectController)) {
      throw TierLimitException(
        'project_create',
        'Max number of projects reached (${currentLimits.maxProjects})')
      ;
    }
  }

  // Snag limits
  bool canCreateSnag(int currentSnagCount) {
    final limits = currentLimits;
    if (limits.maxSnagsPerProject == -1) return true;
    return currentSnagCount < limits.maxSnagsPerProject;
  }

  void checkSnagLimit(int currentSnagCount) {
    if (!canCreateSnag(currentSnagCount)) {
      throw TierLimitException(
        'issue_create',
        'Max number of ${AppStrings.snags()} per project reached (${currentLimits.maxSnagsPerProject})'
      );
    }
  }

  // Feature access checks
  void checkPdfExport() {
    if(!currentLimits.allowPdfExport) {
      throw TierLimitException('pdf_export', 'PDF export not allowed');
    }
  }

  void checkPdfQualityChange() {
    if (!currentLimits.allowPdfQualityChange) {
      throw TierLimitException('pdf_quality_change', 'PDF quality change not allowed');
    }
  }

  void checkPdfThemeChange() {
    if (!currentLimits.allowPdfThemeChange) {
      throw TierLimitException('pdf_theme_change', 'PDF theme change not allowed');
    }
  }

  void checkPdfCustomizer() {
    if (!currentLimits.allowPdfCustomizer) {
      throw TierLimitException('pdf_customizer', 'PDF customizer not allowed');
    }
  }

  void checkCsvExport() {
    if (!currentLimits.allowCsvExport) {
      throw TierLimitException('csv_export', 'CSV export not allowed');
    }
  }

void checkCreateCategory() {
    if (!currentLimits.allowCreateCategory) {
      throw TierLimitException('category_create', 'Category creation not allowed');
    }
  }

  void checkCreateTag() {
    if (!currentLimits.allowCreateTag) {
      throw TierLimitException('tag_create', 'Tag creation not allowed');
    }
  }

  bool get canExportPdf => currentLimits.allowPdfExport;
  bool get canPdfThemeChange => currentLimits.allowPdfThemeChange;
  bool get canPdfQualityChange => currentLimits.allowPdfQualityChange;
  bool get canPdfCustomizer => currentLimits.allowPdfCustomizer;

  bool get canExportCsv => currentLimits.allowCsvExport;
  bool get canCreateCategory => currentLimits.allowCreateCategory;
  bool get canCreateTag => currentLimits.allowCreateTag;
  bool get canCustomizePdf => currentLimits.allowPdfCustomizer;

}
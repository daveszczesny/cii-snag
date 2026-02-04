class TierLimits {
  final int maxProjects;
  final int maxSnagsPerProject;

  final bool allowPdfExport;
  final bool allowPdfThemeChange;
  final bool allowPdfQualityChange;
  final bool allowPdfCustomizer;
  
  final bool allowCsvExport;
  
  final bool allowCreateCategory;
  final int maxCategories;

  final bool allowCreateTag;
  final int maxTags;

  const TierLimits({
    required this.maxProjects,
    required this.maxSnagsPerProject,
    required this.allowPdfExport,
    required this.allowPdfThemeChange,
    required this.allowPdfQualityChange,
    required this.allowPdfCustomizer,
    required this.allowCsvExport,
    required this.allowCreateCategory,
    required this.maxCategories,
    required this.allowCreateTag,
    required this.maxTags,
  });

  static const TierLimits free = TierLimits(
    maxProjects: 2,
    maxSnagsPerProject: 10,
    allowPdfExport: true,
    allowPdfThemeChange: false,
    allowPdfQualityChange: false,
    allowPdfCustomizer: false,
    allowCsvExport: false,
    allowCreateCategory: false,
    maxCategories: -1,
    allowCreateTag: true,
    maxTags: 5,
  );

  static const TierLimits pro = TierLimits(
    maxProjects: -1, // unlimited
    maxSnagsPerProject: 1000,
    allowPdfExport: true,
    allowPdfThemeChange: true,
    allowPdfQualityChange: true,
    allowPdfCustomizer: true,
    allowCsvExport: true,
    allowCreateCategory: true,
    maxCategories: -1,
    allowCreateTag: true,
    maxTags: -1
  );
}
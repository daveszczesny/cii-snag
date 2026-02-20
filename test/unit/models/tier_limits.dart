import 'package:flutter_test/flutter_test.dart';
import 'package:cii/models/tier_limits.dart';

void main() {
  group("TierLimits Model Tests", () {

    test("should create tier limits with all fields", () {
      const tierLimits = TierLimits(
        maxProjects: 5,
        maxSnagsPerProject: 100,
        allowPdfExport: true,
        allowPdfThemeChange: false,
        allowPdfQualityChange: true,
        allowPdfCustomizer: false,
        allowCsvExport: true,
        allowCreateCategory: false,
        maxCategories: 10,
        allowCreateTag: true,
        maxTags: 20,
      );

      expect(tierLimits.maxProjects, 5);
      expect(tierLimits.maxSnagsPerProject, 100);
      expect(tierLimits.allowPdfExport, true);
      expect(tierLimits.allowPdfThemeChange, false);
      expect(tierLimits.allowPdfQualityChange, true);
      expect(tierLimits.allowPdfCustomizer, false);
      expect(tierLimits.allowCsvExport, true);
      expect(tierLimits.allowCreateCategory, false);
      expect(tierLimits.maxCategories, 10);
      expect(tierLimits.allowCreateTag, true);
      expect(tierLimits.maxTags, 20);
    });

    test("should have free tier with correct limits", () {
      expect(TierLimits.free.maxProjects, 2);
      expect(TierLimits.free.maxSnagsPerProject, 10);
      expect(TierLimits.free.allowPdfExport, true);
      expect(TierLimits.free.allowPdfThemeChange, false);
      expect(TierLimits.free.allowPdfQualityChange, false);
      expect(TierLimits.free.allowPdfCustomizer, false);
      expect(TierLimits.free.allowCsvExport, false);
      expect(TierLimits.free.allowCreateCategory, false);
      expect(TierLimits.free.maxCategories, -1);
      expect(TierLimits.free.allowCreateTag, true);
      expect(TierLimits.free.maxTags, 5);
    });

    test("should have pro tier with correct limits", () {
      expect(TierLimits.pro.maxProjects, -1);
      expect(TierLimits.pro.maxSnagsPerProject, 3000);
      expect(TierLimits.pro.allowPdfExport, true);
      expect(TierLimits.pro.allowPdfThemeChange, true);
      expect(TierLimits.pro.allowPdfQualityChange, true);
      expect(TierLimits.pro.allowPdfCustomizer, true);
      expect(TierLimits.pro.allowCsvExport, true);
      expect(TierLimits.pro.allowCreateCategory, true);
      expect(TierLimits.pro.maxCategories, -1);
      expect(TierLimits.pro.allowCreateTag, true);
      expect(TierLimits.pro.maxTags, -1);
    });

  });
}
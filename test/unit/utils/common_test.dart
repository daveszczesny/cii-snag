import 'package:flutter_test/flutter_test.dart';
import 'package:cii/utils/common.dart';

void main() {
  group("Common Utils Tests", () {

    test("should capitalize first letter", () {
      expect(capitilize("hello"), "Hello");
      expect(capitilize("world"), "World");
      expect(capitilize("a"), "A");
      expect(capitilize("TEST"), "TEST");
    });

    test("should parse various date formats", () {
      expect(parseDate("25/12/2023"), isA<DateTime>());
      expect(parseDate("25.12.2023"), isA<DateTime>());
      expect(parseDate("25-12-2023"), isA<DateTime>());
      expect(parseDate("2023/12/25"), isA<DateTime>());
      expect(parseDate("2023-12-25"), isA<DateTime>());
    });

    test("should return null for invalid dates", () {
      expect(parseDate(""), isNull);
      expect(parseDate("invalid"), isNull);
      expect(parseDate("32/13/2023"), isNull);
      expect(parseDate("abc/def/ghij"), isNull);
    });

    test("should format date using default pattern", () {
      final date = DateTime(2023, 12, 25);
      final formatted = formatDate(date);
      expect(formatted, isA<String>());
      expect(formatted.contains("25"), isTrue);
      expect(formatted.contains("12"), isTrue);
      expect(formatted.contains("2023"), isTrue);
    });

    test("should format file sizes correctly", () {
      expect(formatFileSize(500), "500 B");
      expect(formatFileSize(1024), "1.0 KB");
      expect(formatFileSize(1536), "1.5 KB");
      expect(formatFileSize(1048576), "1.0 MB");
      expect(formatFileSize(2097152), "2.0 MB");
      expect(formatFileSize(1572864), "1.5 MB");
    });

    test("should handle edge cases in file size formatting", () {
      expect(formatFileSize(0), "0 B");
      expect(formatFileSize(1), "1 B");
      expect(formatFileSize(1023), "1023 B");
      expect(formatFileSize(1025), "1.0 KB");
    });

    // Note: saveImageToAppDir, getImagePath, getPdfDirectory, and getCsvDirectory
    // require file system operations and are better tested as integration tests

  });
}
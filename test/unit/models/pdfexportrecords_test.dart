import 'package:flutter_test/flutter_test.dart';
import 'package:cii/models/pdfexportrecords.dart';

void main() {
  group("PdfExportRecords Model Tests", () {

    test("should create pdf export record with required fields", () {
      final exportDate = DateTime.now();
      final record = PdfExportRecords(
        exportDate: exportDate,
        fileName: "export.pdf",
        fileHash: "abc123hash",
        fileSize: 2048,
      );

      expect(record.exportDate, exportDate);
      expect(record.fileName, "export.pdf");
      expect(record.fileHash, "abc123hash");
      expect(record.fileSize, 2048);
      expect(record.uuid, isNotNull);
    });

    test("should generate unique uuid when not provided", () {
      final record1 = PdfExportRecords(
        exportDate: DateTime.now(),
        fileName: "file1.pdf",
        fileHash: "hash1",
        fileSize: 1024,
      );
      final record2 = PdfExportRecords(
        exportDate: DateTime.now(),
        fileName: "file2.pdf",
        fileHash: "hash2",
        fileSize: 2048,
      );

      expect(record1.uuid, isNotNull);
      expect(record2.uuid, isNotNull);
      expect(record1.uuid, isNot(equals(record2.uuid)));
    });

    test("should use provided uuid", () {
      const customUuid = "custom-pdf-uuid-123";
      final record = PdfExportRecords(
        uuid: customUuid,
        exportDate: DateTime.now(),
        fileName: "custom.pdf",
        fileHash: "customhash",
        fileSize: 4096,
      );

      expect(record.uuid, customUuid);
    });

  });
}
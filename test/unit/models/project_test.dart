import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/comment.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/models/category.dart';
import 'package:cii/models/pdfexportrecords.dart';
import 'package:cii/models/csvexportrecords.dart';

void main() {
  group("Project Model Tests", () {

    test("should create project with default values", () {
      final project = Project(name: "Test Project");

      expect(project.name, "Test Project");
      expect(project.uuid, isNotNull);
      expect(project.id, isNotNull);
      expect(project.dateCreated, isA<DateTime>());
      expect(project.dateModified, isA<DateTime>());
      expect(project.status, Status.todo);
      expect(project.createdCategories, isEmpty);
      expect(project.createdTags, isEmpty);
      expect(project.snagsCreatedCount, 0);
      expect(project.snags, isEmpty);
    });

    test("should create project with all optional fields", () {
      final comment = Comment(text: "Project comment");
      final tag = Tag(name: "urgent", color: Colors.red);
      final category = Category(name: "electrical", color: Colors.blue);
      final dateCreated = DateTime.now();
      final dateModified = DateTime.now().add(const Duration(hours: 1));
      final dueDate = DateTime.now().add(const Duration(days: 30));
      final dateCompleted = DateTime.now().add(const Duration(days: 25));
      final pdfRecord = PdfExportRecords(
        exportDate: DateTime.now(),
        fileName: "export.pdf",
        fileHash: "hash123",
        fileSize: 1024,
      );
      final csvRecord = CsvExportRecords(
        exportDate: DateTime.now(),
        fileName: "export.csv",
        fileHash: "hash456",
        fileSize: 512,
      );

      final project = Project(
        name: "Complete Project",
        id: "CUSTOM-001",
        description: "Test Description",
        mainImagePath: "image.jpg",
        comments: [comment],
        dateCreated: dateCreated,
        dateModified: dateModified,
        dueDate: dueDate,
        dateCompleted: dateCompleted,
        projectRef: "REF-123",
        client: "Test Client",
        contractor: "Test Contractor",
        finalRemarks: "Final remarks",
        location: "Test Location",
        status: Status.completed,
        createdCategories: [category],
        createdTags: [tag],
        snagsCreatedCount: 5,
      );

      project.pdfExportRecords = [pdfRecord];
      project.csvExportRecords = [csvRecord];

      expect(project.name, "Complete Project");
      expect(project.id, "CUSTOM-001");
      expect(project.description, "Test Description");
      expect(project.mainImagePath, "image.jpg");
      expect(project.comments, [comment]);
      expect(project.dateCreated, dateCreated);
      expect(project.dateModified, dateModified);
      expect(project.dueDate, dueDate);
      expect(project.dateCompleted, dateCompleted);
      expect(project.projectRef, "REF-123");
      expect(project.client, "Test Client");
      expect(project.contractor, "Test Contractor");
      expect(project.finalRemarks, "Final remarks");
      expect(project.location, "Test Location");
      expect(project.status, Status.completed);
      expect(project.createdCategories, [category]);
      expect(project.createdTags, [tag]);
      expect(project.snagsCreatedCount, 5);
      expect(project.pdfExportRecords, [pdfRecord]);
      expect(project.csvExportRecords, [csvRecord]);
    });

    test("should update project properties", () {
      final project = Project(name: "Test Project");

      project.name = "Updated Project";
      project.description = "Updated Description";
      project.status = Status.inProgress;
      project.snagsCreatedCount = 10;

      expect(project.name, "Updated Project");
      expect(project.description, "Updated Description");
      expect(project.status, Status.inProgress);
      expect(project.snagsCreatedCount, 10);
    });

    test("should generate human readable id from name", () {
      expect(Project.humanReadableId("Test Project"), "TES");
      expect(Project.humanReadableId("My New Project"), "MYN");
      expect(Project.humanReadableId("ABC"), "ABC");
      expect(Project.humanReadableId("A!@#B\$%^C&*()"), "ABC");
    });

    test("should handle short names in human readable id", () {
      final id1 = Project.humanReadableId("AB");
      final id2 = Project.humanReadableId("A");
      final id3 = Project.humanReadableId("");

      expect(id1.length, 3);
      expect(id2.length, 3);
      expect(id3.length, 3);
      expect(id1.startsWith("AB"), isTrue);
      expect(id2.startsWith("A"), isTrue);
    });

    test("should use generated id when not provided", () {
      final project = Project(name: "Test Project");
      expect(project.id, "TES");
    });

  });
}
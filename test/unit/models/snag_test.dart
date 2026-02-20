import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/priority.dart';
import 'package:cii/models/comment.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/models/category.dart';

void main() {
  group("Snag Model Tests", () {

    test("should create snag with default values", () {
      final snag = Snag(name: "Test Snag");

      expect(snag.name, "Test Snag");
      expect(snag.status, Status.todo);
      expect(snag.priority, Priority.low);
      expect(snag.dateCreated, isA<DateTime>());
      expect(snag.uuid, isNotNull);
      expect(snag.dateClosed, isNull);
      expect(snag.description, isNull);
    });

    test("should create snag with assigned values", () {

      final dateCreated = DateTime.now();
      final dateModified = DateTime.now().add(const Duration(days: 1));
      final dueDate = DateTime.now().add(const Duration(days: 7));

      final snag = Snag(
        name: "Test Snag",
        description: "Test Description",
        dateCreated: dateCreated,
        status: Status.blocked,
        priority: Priority.high,
        imagePaths: ["test1.png", "test2.png"],
        annotatedImagePaths: {"test1.png": "test1_annotated.png"},
        assignee: "John Smith",
        finalRemarks: "Final remarks",
        location: "Test Location",
        lastModified: dateModified,
        dueDate: dueDate,
      );

      expect(snag.name, "Test Snag");
      expect(snag.description, "Test Description");
      expect(snag.dateCreated, dateCreated);
      expect(snag.status, Status.blocked);
      expect(snag.priority, Priority.high);
      expect(snag.imagePaths, ["test1.png", "test2.png"]);
      expect(snag.annotatedImagePaths, {"test1.png": "test1_annotated.png"});
      expect(snag.assignee, "John Smith");
      expect(snag.finalRemarks, "Final remarks");
      expect(snag.location, "Test Location");
      expect(snag.lastModified, dateModified);
      expect(snag.dueDate, dueDate);
    });

    test("should update snag properties on manual assignment", () {
      final snag = Snag(name: "Test Snag");

      snag.name = "Updated Snag";
      snag.description = "Updated Description";
      snag.status = Status.inProgress;
      snag.priority = Priority.medium;
      snag.assignee = "Jane Doe";

      expect(snag.name, "Updated Snag");
      expect(snag.description, "Updated Description");
      expect(snag.status, Status.inProgress);
      expect(snag.priority, Priority.medium);
    });

    test("should create snag with all optional fields", () {
      final comment = Comment(text: "Test comment");
      final tag = Tag(name: "urgent", color: Colors.red);
      final category = Category(name: "electrical", color: Colors.blue);
      final dateCompleted = DateTime.now();

      final snag = Snag(
        name: "Complete Snag",
        id: "CUSTOM-001",
        projectId: "proj-123",
        comments: [comment],
        dateCompleted: dateCompleted,
        tags: [tag],
        categories: [category],
        reviewedBy: "Reviewer Name",
      );

      expect(snag.id, "CUSTOM-001");
      expect(snag.projectId, "proj-123");
      expect(snag.comments, [comment]);
      expect(snag.dateCompleted, dateCompleted);
      expect(snag.tags, [tag]);
      expect(snag.categories, [category]);
      expect(snag.reviewedBy, "Reviewer Name");
    });

    test("should allow manual assignment of progress and final image paths", () {
      final snag = Snag(name: "Test Snag");
      
      snag.progressImagePaths = ["progress1.jpg"];
      snag.finalImagePaths = ["final1.jpg"];

      expect(snag.progressImagePaths, ["progress1.jpg"]);
      expect(snag.finalImagePaths, ["final1.jpg"]);
    });

    test("should generate default id when not provided", () {
      final snag = Snag(name: "Test Snag");
      expect(snag.id, "PID");
    });

    test("should handle empty lists and maps", () {
      final snag = Snag(
        name: "Test Snag",
        imagePaths: [],
        annotatedImagePaths: {},
        comments: [],
        tags: [],
        categories: [],
      );

      expect(snag.imagePaths, isEmpty);
      expect(snag.annotatedImagePaths, isEmpty);
      expect(snag.comments, isEmpty);
      expect(snag.tags, isEmpty);
      expect(snag.categories, isEmpty);
    });

    test("should maintain dateClosed as null on creation", () {
      final snag = Snag(name: "Test Snag");
      expect(snag.dateClosed, isNull);
    });

  });
}
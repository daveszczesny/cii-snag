import 'package:flutter_test/flutter_test.dart';
import 'package:cii/controllers/snag_controller.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/priority.dart';
import 'package:cii/models/comment.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/models/category.dart';
import 'package:flutter/material.dart';

// Test controller that overrides notification trigger
class TestSnagController extends SnagController {
  TestSnagController(super.snag);
  
  @override
  void triggerNotificationCheck() {
    // Do nothing in tests
  }
}

void main() {
  group("SnagController Tests", () {
    late Snag testSnag;
    late TestSnagController controller;

    setUp(() {
      testSnag = Snag(name: "Test Snag");
      controller = TestSnagController(testSnag);
    });

    group("Getters - Happy Path", () {
      test("should return correct id", () {
        expect(controller.getId, testSnag.id);
      });

      test("should return correct date created", () {
        expect(controller.dateCreated, testSnag.dateCreated);
      });

      test("should return correct name", () {
        expect(controller.name, "Test Snag");
      });

      test("should return correct status", () {
        expect(controller.status, Status.todo);
      });

      test("should return correct priority", () {
        expect(controller.priority, Priority.low);
      });

      test("should return empty string for null assignee", () {
        expect(controller.assignee, "");
      });

      test("should return empty string for null location", () {
        expect(controller.location, "");
      });

      test("should return empty string for null description", () {
        expect(controller.description, "");
      });

      test("should return empty string for null final remarks", () {
        expect(controller.finalRemarks, "");
      });

      test("should return empty string for null reviewed by", () {
        expect(controller.reviewedBy, "");
      });

      test("should return empty list for null image paths", () {
        expect(controller.imagePaths, isEmpty);
      });

      test("should return empty map for null annotated image paths", () {
        expect(controller.annotatedImagePaths, isEmpty);
      });

      test("should return empty list for null progress image paths", () {
        expect(controller.progressImagePaths, isEmpty);
      });

      test("should return empty list for null comments", () {
        expect(controller.comments, isEmpty);
      });

      test("should return empty list for null tags", () {
        expect(controller.tags, isEmpty);
      });

      test("should return empty list for null categories", () {
        expect(controller.categories, isEmpty);
      });

      test("should return empty list for null final image paths", () {
        expect(controller.finalImagePaths, isEmpty);
      });
    });

    group("Getters with Data - Happy Path", () {
      setUp(() {
        testSnag.assignee = "John Doe";
        testSnag.location = "Room 101";
        testSnag.description = "Test description";
        testSnag.finalRemarks = "Test remarks";
        testSnag.reviewedBy = "Jane Smith";
        testSnag.imagePaths = ["image1.jpg"];
        testSnag.annotatedImagePaths = {"image1.jpg": "annotated1.jpg"};
        testSnag.progressImagePaths = ["progress1.jpg"];
        testSnag.finalImagePaths = ["final1.jpg"];
        testSnag.dueDate = DateTime(2024, 12, 25);
        testSnag.dateClosed = DateTime(2024, 12, 20);
        testSnag.comments = [Comment(text: "Test comment")];
        testSnag.tags = [Tag(name: "urgent")];
        testSnag.categories = [Category(name: "electrical")];
      });

      test("should return assignee when set", () {
        expect(controller.assignee, "John Doe");
      });

      test("should return location when set", () {
        expect(controller.location, "Room 101");
      });

      test("should return description when set", () {
        expect(controller.description, "Test description");
      });

      test("should return final remarks when set", () {
        expect(controller.finalRemarks, "Test remarks");
      });

      test("should return reviewed by when set", () {
        expect(controller.reviewedBy, "Jane Smith");
      });

      test("should return image paths when set", () {
        expect(controller.imagePaths, ["image1.jpg"]);
      });

      test("should return annotated image paths when set", () {
        expect(controller.annotatedImagePaths, {"image1.jpg": "annotated1.jpg"});
      });

      test("should return progress image paths when set", () {
        expect(controller.progressImagePaths, ["progress1.jpg"]);
      });

      test("should return final image paths when set", () {
        expect(controller.finalImagePaths, ["final1.jpg"]);
      });

      test("should return due date when set", () {
        expect(controller.getDueDate, DateTime(2024, 12, 25));
      });

      test("should return due date string when set", () {
        expect(controller.getDueDateString, isNotNull);
      });

      test("should return date closed when set", () {
        expect(controller.getDateClosed, DateTime(2024, 12, 20));
      });

      test("should return date closed string when set", () {
        expect(controller.getDateClosedString, isNotNull);
      });

      test("should return comments when set", () {
        expect(controller.comments, hasLength(1));
        expect(controller.comments[0].text, "Test comment");
      });

      test("should return tags when set", () {
        expect(controller.tags, hasLength(1));
        expect(controller.tags[0].name, "urgent");
      });

      test("should return categories when set", () {
        expect(controller.categories, hasLength(1));
        expect(controller.categories[0].name, "electrical");
      });
    });

    group("Status and Completion Logic", () {
      test("should return false for isClosed when status is not completed", () {
        expect(controller.isClosed, false);
      });

      test("should return true for isClosed when status is completed", () {
        controller.status = Status.completed;
        expect(controller.isClosed, true);
      });

      test("should update last modified when status is set", () {
        final beforeTime = DateTime.now();
        controller.status = Status.inProgress;
        expect(testSnag.lastModified!.isAfter(beforeTime), true);
      });
    });

    group("Setters - Happy Path", () {
      test("should set name and update last modified", () {
        final beforeTime = DateTime.now();
        controller.setName("Updated Name");
        expect(testSnag.name, "Updated Name");
        expect(testSnag.lastModified!.isAfter(beforeTime), true);
      });

      test("should set description and update last modified", () {
        final beforeTime = DateTime.now();
        controller.setDescription("Updated Description");
        expect(testSnag.description, "Updated Description");
        expect(testSnag.lastModified!.isAfter(beforeTime), true);
      });

      test("should set location and update last modified", () {
        final beforeTime = DateTime.now();
        controller.setLocation("Updated Location");
        expect(testSnag.location, "Updated Location");
        expect(testSnag.lastModified!.isAfter(beforeTime), true);
      });

      test("should set assignee and update last modified", () {
        final beforeTime = DateTime.now();
        controller.setAssignee("Updated Assignee");
        expect(testSnag.assignee, "Updated Assignee");
        expect(testSnag.lastModified!.isAfter(beforeTime), true);
      });

      test("should set final remarks and update last modified", () {
        final beforeTime = DateTime.now();
        controller.setFinalRemarks("Updated Remarks");
        expect(testSnag.finalRemarks, "Updated Remarks");
        expect(testSnag.lastModified!.isAfter(beforeTime), true);
      });

      test("should set reviewed by and update last modified", () {
        final beforeTime = DateTime.now();
        controller.setReviewedBy("Updated Reviewer");
        expect(testSnag.reviewedBy, "Updated Reviewer");
        expect(testSnag.lastModified!.isAfter(beforeTime), true);
      });

      test("should set due date and update last modified", () {
        final beforeTime = DateTime.now();
        controller.setDueDate("25/12/2024");
        expect(testSnag.dueDate, isNotNull);
        expect(testSnag.lastModified!.isAfter(beforeTime), true);
      });

      test("should set date closed and update last modified", () {
        final beforeTime = DateTime.now();
        controller.setDateClosed("20/12/2024");
        expect(testSnag.dateClosed, isNotNull);
        expect(testSnag.lastModified!.isAfter(beforeTime), true);
      });

      test("should set final image paths", () {
        controller.setFinalImagePaths(["final1.jpg", "final2.jpg"]);
        expect(testSnag.finalImagePaths, ["final1.jpg", "final2.jpg"]);
      });

      test("should add progress image path", () {
        controller.addProgressImagePath("progress1.jpg");
        expect(testSnag.progressImagePaths, ["progress1.jpg"]);
      });

      test("should add multiple progress image paths", () {
        controller.addProgressImagePath("progress1.jpg");
        controller.addProgressImagePath("progress2.jpg");
        expect(testSnag.progressImagePaths, ["progress1.jpg", "progress2.jpg"]);
      });
    });

    group("Tag Management - Happy Path", () {
      test("should add tag and update last modified", () {
        final beforeTime = DateTime.now();
        final tag = Tag(name: "urgent", color: Colors.red);
        controller.setTag(tag);
        expect(testSnag.tags, [tag]);
        expect(testSnag.lastModified!.isAfter(beforeTime), true);
      });

      test("should find tag by name", () {
        final tag = Tag(name: "urgent", color: Colors.red);
        controller.setTag(tag);
        expect(controller.getTagByName("urgent"), tag);
      });

      test("should remove tag by name", () {
        final tag = Tag(name: "urgent", color: Colors.red);
        controller.setTag(tag);
        controller.removeTagByName("urgent");
        expect(testSnag.tags, isEmpty);
      });
    });

    group("Tag Management - Unhappy Path", () {
      test("should return null when tag not found", () {
        expect(controller.getTagByName("nonexistent"), isNull);
      });

      test("should return null when tags list is empty", () {
        testSnag.tags = [];
        expect(controller.getTagByName("urgent"), isNull);
      });

      test("should handle removing non-existent tag gracefully", () {
        expect(() => controller.removeTagByName("nonexistent"), returnsNormally);
      });

      test("should handle removing tag from empty list gracefully", () {
        testSnag.tags = [];
        expect(() => controller.removeTagByName("urgent"), returnsNormally);
      });
    });

    group("Category Management - Happy Path", () {
      test("should set category and update last modified", () {
        final beforeTime = DateTime.now();
        final category = Category(name: "electrical", color: Colors.blue);
        controller.setCategory(category);
        expect(testSnag.categories, [category]);
        expect(testSnag.lastModified!.isAfter(beforeTime), true);
      });

      test("should replace existing category when setting new one", () {
        final category1 = Category(name: "electrical", color: Colors.blue);
        final category2 = Category(name: "plumbing", color: Colors.orange);
        controller.setCategory(category1);
        controller.setCategory(category2);
        expect(testSnag.categories, [category2]);
        expect(testSnag.categories, hasLength(1));
      });

      test("should find category by name", () {
        final category = Category(name: "electrical", color: Colors.blue);
        controller.setCategory(category);
        expect(controller.getCategoryByName("electrical"), category);
      });

      test("should remove category by name", () {
        final category = Category(name: "electrical", color: Colors.blue);
        controller.setCategory(category);
        controller.removeCategoryByName("electrical");
        expect(testSnag.categories, isEmpty);
      });
    });

    group("Category Management - Unhappy Path", () {
      test("should return null when category not found", () {
        expect(controller.getCategoryByName("nonexistent"), isNull);
      });

      test("should return null when categories list is empty", () {
        testSnag.categories = [];
        expect(controller.getCategoryByName("electrical"), isNull);
      });

      test("should return null when categories list is null", () {
        testSnag.categories = null;
        expect(controller.getCategoryByName("electrical"), isNull);
      });
    });

    group("Date Parsing - Unhappy Path", () {
      test("should handle invalid due date format", () {
        expect(() => controller.setDueDate("invalid-date"), throwsFormatException);
      });

      test("should handle invalid date closed format", () {
        expect(() => controller.setDateClosed("invalid-date"), throwsFormatException);
      });
    });

    group("Null Safety", () {
      test("should handle null due date gracefully", () {
        expect(controller.getDueDate, isNull);
        expect(controller.getDueDateString, isNull);
      });

      test("should handle null date closed gracefully", () {
        expect(controller.getDateClosed, isNull);
        expect(controller.getDateClosedString, isNull);
      });

      test("should handle null last modified gracefully", () {
        expect(controller.lastModified, isNull);
      });

      test("should handle null date completed gracefully", () {
        expect(controller.dateCompleted, isNull);
      });
    });

  });
}
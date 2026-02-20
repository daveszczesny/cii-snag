import 'package:flutter_test/flutter_test.dart';
import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/priority.dart';
import 'package:flutter/material.dart';

// Test controller that overrides save to avoid Hive dependency
class TestSingleProjectController extends SingleProjectController {
  TestSingleProjectController(super.project);
  
  @override
  void saveProject() {
    // Do nothing in tests to avoid Hive dependency
  }
  
  @override
  void updateSnag(Snag updatedSnag) {
    int index = project.snags.indexWhere((snag) => snag.uuid == updatedSnag.uuid);
    if (index != -1) {
      project.snags[index] = updatedSnag;
      // Skip project.save() call that causes Hive error
    }
    saveProject();
  }
}

void main() {
  group("SingleProjectController Tests", () {
    late Project testProject;
    late TestSingleProjectController controller;

    setUp(() {
      testProject = Project(name: "Test Project");
      controller = TestSingleProjectController(testProject);
    });

    group("Getters - Happy Path", () {
      test("should return correct project properties", () {
        expect(controller.getName, "Test Project");
        expect(controller.getProjectUUID, testProject.uuid);
        expect(controller.getProjectId, testProject.id);
        expect(controller.getStatus, Status.todo.name);
        expect(controller.getDateCreated, testProject.dateCreated);
      });

      test("should return null for optional properties", () {
        expect(controller.getDescription, isNull);
        expect(controller.getLocation, isNull);
        expect(controller.getClient, isNull);
        expect(controller.getContractor, isNull);
        expect(controller.getProjectRef, isNull);
        expect(controller.getMainImagePath, isNull);
        expect(controller.getDateCompleted, isNull);
        expect(controller.getDueDate, isNull);
        expect(controller.getDueDateString, isNull);
      });

      test("should return empty collections", () {
        expect(controller.getCategories, isEmpty);
        expect(controller.getTags, isEmpty);
        expect(controller.getAllSnags(), isEmpty);
        expect(controller.getTotalSnags(), 0);
      });
    });

    group("Setters - Happy Path", () {
      test("should set project properties", () {
        controller.setName("Updated Project");
        controller.setDescription("Updated Description");
        controller.setLocation("Updated Location");
        controller.setClient("Updated Client");
        controller.setContractor("Updated Contractor");
        controller.setProjectRef("REF-001");

        expect(controller.getName, "Updated Project");
        expect(controller.getDescription, "Updated Description");
        expect(controller.getLocation, "Updated Location");
        expect(controller.getClient, "Updated Client");
        expect(controller.getContractor, "Updated Contractor");
        expect(controller.getProjectRef, "REF-001");
      });

      test("should set main image path", () {
        controller.setMainImagePath("image.jpg");
        expect(controller.getMainImagePath, "image.jpg");
      });

      test("should set status", () {
        controller.setStatus("in progress");
        expect(controller.getStatus, Status.inProgress.name);
      });
    });

    group("Snag Management - Happy Path", () {
      test("should add snag and update project status", () {
        final snag = Snag(name: "Test Snag");
        
        controller.addSnag(snag);
        
        expect(controller.getTotalSnags(), 1);
        expect(controller.getStatus, Status.inProgress.name);
        expect(testProject.snagsCreatedCount, 1);
      });

      test("should update existing snag", () {
        final snag = Snag(name: "Original Snag");
        controller.addSnag(snag);
        
        snag.name = "Updated Snag";
        controller.updateSnag(snag);
        
        expect(controller.getAllSnags()[0].name, "Updated Snag");
      });

      test("should delete snag", () {
        final snag = Snag(name: "Test Snag");
        controller.addSnag(snag);
        
        controller.deleteSnag(snag);
        
        expect(controller.getTotalSnags(), 0);
      });
    });

    group("Snag Filtering and Querying", () {
      setUp(() {
        // Add test snags with different statuses and priorities
        final snag1 = Snag(name: "Snag 1", status: Status.todo, priority: Priority.high);
        final snag2 = Snag(name: "Snag 2", status: Status.completed, priority: Priority.low);
        final snag3 = Snag(name: "Snag 3", status: Status.inProgress, priority: Priority.medium);
        
        controller.addSnag(snag1);
        controller.addSnag(snag2);
        controller.addSnag(snag3);
      });

      test("should get snags by status", () {
        final todoSnags = controller.getSnagsByStatus(Status.todo);
        final completedSnags = controller.getSnagsByStatus(Status.completed);
        
        expect(todoSnags, hasLength(1));
        expect(completedSnags, hasLength(1));
        expect(todoSnags[0].name, "Snag 1");
        expect(completedSnags[0].name, "Snag 2");
      });

      test("should get snags by priority", () {
        final highPrioritySnags = controller.getSnagsByPriority("high");
        final lowPrioritySnags = controller.getSnagsByPriority("low");
        
        expect(highPrioritySnags, hasLength(1));
        expect(lowPrioritySnags, hasLength(1));
        expect(highPrioritySnags[0].name, "Snag 1");
        expect(lowPrioritySnags[0].name, "Snag 2");
      });

      test("should count snags by status", () {
        expect(controller.getTotalSnagsByStatus(Status.todo), 1);
        expect(controller.getTotalSnagsByStatus(Status.completed), 1);
        expect(controller.getTotalSnagsByStatus(Status.inProgress), 1);
      });

      test("should count snags by priority", () {
        expect(controller.getTotalSnagsByPriority("high"), 1);
        expect(controller.getTotalSnagsByPriority("low"), 1);
        expect(controller.getTotalSnagsByPriority("medium"), 1);
      });

      test("should calculate snag progress", () {
        // 1 completed out of 3 total = 0.33...
        final progress = controller.getSnagProgress();
        expect(progress, closeTo(0.33, 0.01));
      });

      test("should filter snags", () {
        final allSnags = controller.filterSnags("all");
        final recentSnags = controller.filterSnags("recent");
        
        expect(allSnags, hasLength(3));
        expect(recentSnags, hasLength(3));
        // Should be sorted by date created (most recent first)
        expect(recentSnags[0].name, "Snag 3");
      });
    });

    group("Category and Tag Management", () {
      test("should add and remove categories", () {
        controller.addCategory("Electrical", Colors.blue);
        
        expect(controller.getCategories, hasLength(1));
        expect(controller.getCategories![0].name, "Electrical");
        
        controller.removeCategory("Electrical");
        expect(controller.getCategories, isEmpty);
      });

      test("should add and remove tags", () {
        controller.addTag("Urgent", Colors.red);
        
        expect(controller.getTags, hasLength(1));
        expect(controller.getTags![0].name, "Urgent");
        
        controller.removeTag("Urgent");
        expect(controller.getTags, isEmpty);
      });

      test("should get snags by category", () {
        controller.addCategory("Electrical", Colors.blue);
        final category = controller.getCategories![0];
        
        final snag = Snag(name: "Test Snag", categories: [category]);
        controller.addSnag(snag);
        
        final snagsInCategory = controller.getSnagsByCategory("Electrical");
        expect(snagsInCategory, hasLength(1));
      });

      test("should get snags with no category", () {
        final snag = Snag(name: "Uncategorized Snag");
        controller.addSnag(snag);
        
        final uncategorizedSnags = controller.getSnagsWithNoCategory();
        expect(uncategorizedSnags, hasLength(1));
      });
    });

    group("Update Detail Method", () {
      test("should update project details by key", () {
        controller.updateDetail("name", "New Name");
        controller.updateDetail("description", "New Description");
        controller.updateDetail("location", "New Location");
        controller.updateDetail("client", "New Client");
        controller.updateDetail("contractor", "New Contractor");
        controller.updateDetail("projectRef", "NEW-REF");
        
        expect(controller.getName, "New Name");
        expect(controller.getDescription, "New Description");
        expect(controller.getLocation, "New Location");
        expect(controller.getClient, "New Client");
        expect(controller.getContractor, "New Contractor");
        expect(controller.getProjectRef, "NEW-REF");
      });

      test("should handle unknown key gracefully", () {
        expect(() => controller.updateDetail("unknown", "value"), returnsNormally);
      });

      test("should update due date", () {
        controller.updateDetail("dueDate", "25/12/2024");
        expect(controller.getDueDate, isNotNull);
      });
    });

    group("Edge Cases", () {
      test("should handle empty snag list", () {
        expect(controller.getSnagProgress(), 0.0);
        expect(controller.filterSnags("closed"), isEmpty);
      });

      test("should handle update non-existent snag", () {
        final nonExistentSnag = Snag(name: "Non-existent");
        expect(() => controller.updateSnag(nonExistentSnag), returnsNormally);
      });

      test("should get snags created count", () {
        final snag = Snag(name: "Test Snag");
        controller.addSnag(snag);
        controller.deleteSnag(snag);
        
        // Count should remain 1 even after deletion
        expect(controller.getSnagsCreatedCount(), 1);
        expect(controller.getTotalSnags(), 0);
      });
    });

  });
}
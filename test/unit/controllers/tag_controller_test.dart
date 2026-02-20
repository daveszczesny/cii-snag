import 'package:flutter_test/flutter_test.dart';
import 'package:cii/controllers/tag_controller.dart';
import 'package:cii/models/tag.dart';
import 'package:flutter/material.dart';

void main() {
  group("TagController Tests", () {
    late Tag testTag;
    late TagController controller;

    group("Happy Path", () {
      test("should return correct name", () {
        testTag = Tag(name: "Urgent");
        controller = TagController(testTag);
        
        expect(controller.name, "Urgent");
      });

      test("should return empty string for null description", () {
        testTag = Tag(name: "Test Tag");
        controller = TagController(testTag);
        
        expect(controller.description, "");
      });

      test("should return description when set", () {
        testTag = Tag(name: "Important", description: "High priority items");
        controller = TagController(testTag);
        
        expect(controller.description, "High priority items");
      });

      test("should work with tag that has color", () {
        testTag = Tag(name: "Critical", description: "Critical issues", color: Colors.red);
        controller = TagController(testTag);
        
        expect(controller.name, "Critical");
        expect(controller.description, "Critical issues");
      });
    });

    group("Edge Cases", () {
      test("should handle empty name", () {
        testTag = Tag(name: "");
        controller = TagController(testTag);
        
        expect(controller.name, "");
      });

      test("should handle empty description", () {
        testTag = Tag(name: "Test", description: "");
        controller = TagController(testTag);
        
        expect(controller.description, "");
      });

      test("should handle tag with only name", () {
        testTag = Tag(name: "Simple Tag");
        controller = TagController(testTag);
        
        expect(controller.name, "Simple Tag");
        expect(controller.description, "");
      });
    });

  });
}
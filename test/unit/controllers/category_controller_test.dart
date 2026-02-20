import 'package:flutter_test/flutter_test.dart';
import 'package:cii/controllers/category_controller.dart';
import 'package:cii/models/category.dart';
import 'package:flutter/material.dart';

void main() {
  group("CategoryController Tests", () {
    late Category testCategory;
    late CategoryController controller;

    group("Getters - Happy Path", () {
      test("should return correct name", () {
        testCategory = Category(name: "Electrical");
        controller = CategoryController(testCategory);
        
        expect(controller.name, "Electrical");
      });

      test("should return empty string for null description", () {
        testCategory = Category(name: "Test Category");
        controller = CategoryController(testCategory);
        
        expect(controller.description, "");
      });

      test("should return description when set", () {
        testCategory = Category(name: "Safety", description: "Safety related issues");
        controller = CategoryController(testCategory);
        
        expect(controller.description, "Safety related issues");
      });

      test("should return correct color", () {
        testCategory = Category(name: "Plumbing", color: Colors.orange);
        controller = CategoryController(testCategory);
        
        expect(controller.color, Colors.orange);
      });

      test("should return default color when not specified", () {
        testCategory = Category(name: "General");
        controller = CategoryController(testCategory);
        
        expect(controller.color, Colors.blue);
      });
    });

    group("Setters - Happy Path", () {
      setUp(() {
        testCategory = Category(name: "Test Category");
        controller = CategoryController(testCategory);
      });

      test("should set name", () {
        controller.setName("Updated Category");
        
        expect(controller.name, "Updated Category");
        expect(testCategory.name, "Updated Category");
      });

      test("should set description", () {
        controller.setDescription("Updated description");
        
        expect(controller.description, "Updated description");
        expect(testCategory.description, "Updated description");
      });

      test("should set color", () {
        controller.setColor(Colors.green);
        
        expect(controller.color, Colors.green);
        expect(testCategory.color, Colors.green);
      });

      test("should update all fields", () {
        controller.setName("Complete Category");
        controller.setDescription("Complete description");
        controller.setColor(Colors.purple);
        
        expect(controller.name, "Complete Category");
        expect(controller.description, "Complete description");
        expect(controller.color, Colors.purple);
      });
    });

    group("Edge Cases", () {
      test("should handle empty name", () {
        testCategory = Category(name: "");
        controller = CategoryController(testCategory);
        
        expect(controller.name, "");
      });

      test("should handle setting empty name", () {
        testCategory = Category(name: "Test");
        controller = CategoryController(testCategory);
        
        controller.setName("");
        expect(controller.name, "");
      });

      test("should handle empty description", () {
        testCategory = Category(name: "Test", description: "");
        controller = CategoryController(testCategory);
        
        expect(controller.description, "");
      });

      test("should handle setting empty description", () {
        testCategory = Category(name: "Test", description: "Initial");
        controller = CategoryController(testCategory);
        
        controller.setDescription("");
        expect(controller.description, "");
      });

      test("should handle overwriting existing description", () {
        testCategory = Category(name: "Test", description: "Original");
        controller = CategoryController(testCategory);
        
        controller.setDescription("New description");
        expect(controller.description, "New description");
      });
    });

  });
}
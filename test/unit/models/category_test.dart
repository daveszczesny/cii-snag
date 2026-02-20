import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cii/models/category.dart';

void main() {
  group("Category Model Tests", () {

    test("should create category with required name and default color", () {
      final category = Category(name: "Test Category");

      expect(category.name, "Test Category");
      expect(category.color, Colors.blue);
      expect(category.description, isNull);
    });

    test("should create category with name and custom color", () {
      final category = Category(name: "Electrical", color: Colors.yellow);

      expect(category.name, "Electrical");
      expect(category.color, Colors.yellow);
      expect(category.description, isNull);
    });

    test("should create category with all fields", () {
      final category = Category(
        name: "Safety",
        description: "Safety related issues",
        color: Colors.red,
      );

      expect(category.name, "Safety");
      expect(category.description, "Safety related issues");
      expect(category.color, Colors.red);
    });

    test("should allow updating name", () {
      final category = Category(name: "Test Category");
      
      category.name = "Updated Category";
      
      expect(category.name, "Updated Category");
    });

    test("should allow updating description and color", () {
      final category = Category(name: "Test Category");
      
      category.description = "Updated description";
      category.color = Colors.green;
      
      expect(category.description, "Updated description");
      expect(category.color, Colors.green);
    });

    test("should have default categories", () {
      expect(Category.defaultCategories, hasLength(5));
      expect(Category.defaultCategories.map((c) => c.name), 
        containsAll(['Electrical', 'Plumbing', 'Structural', 'Safety', 'General']));
    });

    test("should sort categories with defaults first", () {
      final categories = [
        Category(name: "Custom"),
        Category(name: "Electrical"),
        Category(name: "Another Custom"),
        Category(name: "Safety"),
      ];

      Category.sortCategories(categories);

      expect(categories[0].name, "Safety");
      expect(categories[1].name, "Electrical");
      expect(categories[2].name, "Custom");
      expect(categories[3].name, "Another Custom");
    });

    test("should handle empty category list in sorting", () {
      final List<Category> categories = [];
      
      expect(() => Category.sortCategories(categories), returnsNormally);
    });

  });
}
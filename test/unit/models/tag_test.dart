import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cii/models/tag.dart';

void main() {
  group("Tag Model Tests", () {

    test("should create tag with required name and default color", () {
      final tag = Tag(name: "Test Tag");

      expect(tag.name, "Test Tag");
      expect(tag.color, Colors.blue);
      expect(tag.description, isNull);
    });

    test("should create tag with name and custom color", () {
      final tag = Tag(name: "Urgent", color: Colors.red);

      expect(tag.name, "Urgent");
      expect(tag.color, Colors.red);
      expect(tag.description, isNull);
    });

    test("should create tag with all fields", () {
      final tag = Tag(
        name: "Important",
        description: "High priority items",
        color: Colors.orange,
      );

      expect(tag.name, "Important");
      expect(tag.description, "High priority items");
      expect(tag.color, Colors.orange);
    });

    test("should allow updating description", () {
      final tag = Tag(name: "Test Tag");
      
      tag.description = "Updated description";
      
      expect(tag.description, "Updated description");
    });

    test("should allow updating color", () {
      final tag = Tag(name: "Test Tag");
      
      tag.color = Colors.green;
      
      expect(tag.color, Colors.green);
    });

  });
}
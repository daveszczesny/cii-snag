import 'package:cii/models/category.dart' as cii;
import 'package:flutter/material.dart';

class CategoryController {
  final cii.Category category;
  CategoryController(this.category);

  String get name {
    return category.name;
  }

  String get description {
    return category.description ?? '';
  }

  Color get color {
    return category.color;
  }

  void setName(String name) {
    category.name = name;
  }

  void setDescription(String description) {
    category.description = description;
  }

  void setColor(Color color) {
    category.color = color;
  }
}

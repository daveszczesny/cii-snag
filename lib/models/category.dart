import 'package:cii/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 3)
class Category extends HiveObject {

  @HiveField(0)
  String name;

  @HiveField(1)
  String? description;

  @HiveField(2)
  Color color;

  Category({
    required this.name,
    this.description,
    this.color = Colors.blue,
  });

   static List<Category> defaultCategories = [
        Category(name: 'Electrical', color: AppColors.electricalBlue),
        Category(name: 'Plumbing', color: AppColors.plumbingOrange),
        Category(name: 'Structural', color: AppColors.structuralGreen),
        Category(name: 'Safety', color: AppColors.safetyRed),
      ];

}
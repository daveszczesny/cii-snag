import 'dart:io';
import 'package:cii/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cii/models/project.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/priority.dart';
import 'package:cii/models/status.dart';

class DemoService {
  static const String _firstLaunchKey = 'first_launch';

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  static Future<void> markFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);
  }

  static Future<void> createDemoData() async {

    final projectImageName = await _copyAssetToFile("lib/assets/demo/project.JPG", "demo_project.JPG");
    final snag1ImagePath = await _copyAssetToFile("lib/assets/demo/snag1.JPG", "demo_snag2.JPG");
    final snag2ImagePath = await _copyAssetToFile("lib/assets/demo/snag2.JPG", "demo_snag1.JPG");

    // Create DEMO project
    final project = Project(
      name: "Demo Kitchen Renovation",
      description: "Example project showing app features",
      client: "Demo Client",
      contractor: "Demo Contractor",
      location: "London, UK",
      projectRef: "DEMO",
      mainImagePath: projectImageName,
      createdCategories: [Category(name: "Painting", color: Colors.lightGreen)]
    );

    project.status = Status.inProgress;

    Snag snag1 = Snag(
        id: 'DEMO-0001',
        projectId: project.uuid,
        name: 'Dripping paint',
        description: 'There is paint drip marks on the wall beside the light switch',
        status: Status.inProgress,
        priority: Priority.medium,
        location: 'Kitchen',
        assignee: 'John Smith',
        categories: [project.createdCategories!.first],
        imagePaths: [snag1ImagePath],
        dueDate: DateTime.now().add(const Duration(days: 5))
      );
      Snag snag2 = Snag(
        id: 'DEMO-0002',
        projectId: project.uuid,
        name: 'Spot not painted',
        description: 'There is a bit of the wall not painted',
        status: Status.blocked,
        priority: Priority.high,
        location: 'Kitchen',
        assignee: 'John Smith',
        categories: [project.createdCategories!.first],
        imagePaths: [snag2ImagePath],
        dueDate: DateTime.now().add(const Duration(days: -1))
      );

      project.snagsCreatedCount = 2;

      final projectBox = Hive.box<Project>("projects");
      final snagBox = Hive.box<Snag>("snags");
      await projectBox.put(project.uuid, project);
      await snagBox.put(snag1.uuid, snag1);
      await snagBox.put(snag2.uuid, snag2);
  }


  static Future<String> _copyAssetToFile(String assetPath, String fileName) async {
    final byteData = await rootBundle.load(assetPath);
    final directory = await getApplicationDocumentsDirectory();
    
    // Create images directory if it doesn't exist
    final imagesDir = Directory('${directory.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    final file = File('${imagesDir.path}/$fileName');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return fileName; // Return just the filename
  }
}

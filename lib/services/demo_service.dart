import 'dart:io';
import 'package:cii/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cii/controllers/project_controller.dart';
import 'package:cii/controllers/single_project_controller.dart';
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

    ProjectController projectController = ProjectController(Hive.box<Project>('projects'));
    // Create DEMO project
    projectController.createProject(
      name: "Demo Kitchen Renovation",
      description: "Sample project showing app features",
      client: "Demo Client",
      contractor: "Demo Contractor",
      location: "London, UK",
      projectRef: "DEMO",
      imagePath: projectImageName
    );

    final projects = projectController.getAllProjects();
    final demoProject = projects.last;

    final singleProjectController = SingleProjectController(demoProject);

    singleProjectController.addCategory("Painting", Colors.lightGreen);

    Snag snag1 = Snag(
        id: 'DEMO-0001',
        projectId: demoProject.id,
        name: 'Dripping paint',
        description: 'There is paint drip marks on the wall beside the light switch',
        status: Status.inProgress,
        priority: Priority.medium,
        location: 'Kitchen',
        assignee: 'John Smith',
        categories: [singleProjectController.getCategories!.first],
        imagePaths: [snag1ImagePath],
        dueDate: DateTime.now().add(const Duration(days: 5))
      );
      Snag snag2 = Snag(
        id: 'DEMO-0002',
        projectId: demoProject.id,
        name: 'Spot not painted',
        description: 'There is a bit of the wall not painted',
        status: Status.blocked,
        priority: Priority.high,
        location: 'Kitchen',
        assignee: 'John Smith',
        categories: [singleProjectController.getCategories!.first],
        imagePaths: [snag2ImagePath],
        dueDate: DateTime.now().add(const Duration(days: -1))
      );

      singleProjectController.addSnag(snag1);
      singleProjectController.addSnag(snag2);
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
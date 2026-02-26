import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/adapters/color_adapter.dart';
import 'package:cii/adapters/priority_enum_adapter.dart';
import 'package:cii/models/category.dart';
import 'package:cii/models/comment.dart';
import 'package:cii/models/csvexportrecords.dart';
import 'package:cii/models/notification.dart';
import 'package:cii/models/pdfexportrecords.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/services/demo_service.dart';
import 'package:cii/services/notification_service.dart';
import 'package:cii/services/background_notification_service.dart';
import 'package:cii/controllers/notification_controller.dart';
import 'package:cii/view/settings/settings.dart';
import 'package:cii/theme.dart';
import 'package:cii/view/screen.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cii/services/premium_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await PremiumService.instance.init();

    await Hive.initFlutter();

    try {
      Hive.registerAdapter(ColorAdapter());
      Hive.registerAdapter(PriorityAdapter());
      Hive.registerAdapter(CommentAdapter());
      Hive.registerAdapter(CategoryAdapter());
      Hive.registerAdapter(TagAdapter());
      Hive.registerAdapter(ProjectAdapter());
      Hive.registerAdapter(StatusAdapter());
      Hive.registerAdapter(SnagAdapter());
      Hive.registerAdapter(PdfExportRecordsAdapter());
      Hive.registerAdapter(CsvExportRecordsAdapter());
      Hive.registerAdapter(NotificationTypeAdapter());
      Hive.registerAdapter(AppNotificationAdapter());
    } catch (e) {
      debugPrint("Error registerin hive adapters: $e");
    }

    // load user preferences
    try {
      AppTerminology.loadTerminologyPrefs();
      AppDateTimeFormat.loadDateTimePrefs();
    } catch (e) {
      debugPrint("Error loading preferences $e");
    }

    try {
      await Hive.openBox<Project>('projects');
      await Hive.openBox<Snag>('snags');
      await Hive.openBox<Category>('categories');
      await Hive.openBox<Tag>('tags');
      await Hive.openBox<AppNotification>('notifications');
    } catch (e) {
      debugPrint("Error opening Hive boxes: $e");
    }

    // migration script
    try {
      final projectBox = Hive.box<Project>("projects");
      final snagBox = Hive.box<Snag>("snags");

      for (final project in projectBox.values) {
        if (project.snags.isNotEmpty) {
          // migrate embedded snags to snag provider
          for (final snag in project.snags) {
            final updatedSnag = snag.copyWith(projectId: project.uuid);
            snagBox.put(snag.uuid, updatedSnag);
          }
          project.snags.clear();
        }
      }
    } catch (e) {
      debugPrint("Error migrating snags to providers");
    }

    try {
      final projectBox = Hive.box<Project>("projects");
      final snagBox = Hive.box<Snag>("snags");
      final projectsToMigrate = <String, Project>{};

      for (final key in projectBox.keys.toList()) {
        final project = projectBox.get(key);
        if (project != null && key.toString() != project.uuid) {
          projectsToMigrate[key.toString()] = project;
        }
      }

      for (final entry in projectsToMigrate.entries) {
        final oldKey = entry.key;
        final project = entry.value;
        final newProject = project.copyWith();
        projectBox.delete(int.parse(oldKey));
        projectBox.put(project.uuid, newProject);
      }


      // migrate snags
      final snagsToMigrate = <String, Snag>{};
      for (final key in snagBox.keys.toList()) {
        final snag = snagBox.get(key);
        if (snag != null && key.toString() != snag.uuid) {
          snagsToMigrate[key.toString()] = snag;
        }
      }

      for (final entry in snagsToMigrate.entries) {
        final oldKey = entry.key;
        final snag = entry.value;
        final newSnag = snag.copyWith();
        snagBox.delete(int.parse(oldKey));
        snagBox.put(snag.uuid, newSnag);
      }
    } catch (e) {
      debugPrint("Error migrating project/snag keys: $e");
    }

    try {
      // Initialize notification service
      await NotificationService().initialize();
      
      // Check for notifications on app start
      final notificationController = NotificationController();
      await notificationController.checkAndCreateNotifications();
      
      // Start background notification checks
      await BackgroundNotificationService.initialize();
    } catch (e) {
      debugPrint("Error initializing notifications: $e"); 
    } 

    try {
      // Create demo data if first launch
      final isFirstLaunch = await DemoService.isFirstLaunch();
      if (isFirstLaunch) {
        await DemoService.createDemoData();
      }
    } catch (e) {
      debugPrint("Error creating demo data: $e");
    }


    runApp(const ProviderScope(child: MainApp()));
  } catch (e) {
    debugPrint("Error initializing app: $e");
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      home: const Screen(),
      routes: {
        '/settings': (context) => const SettingsPage(),
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2)
            )
          ),
          child: child!
        );
      },
    );
  }
}

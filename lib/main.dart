import 'package:cii/adapters/color_adapter.dart';
import 'package:cii/adapters/priority_enum_adapter.dart';
import 'package:cii/models/category.dart';
import 'package:cii/models/comment.dart';
import 'package:cii/models/company.dart';
import 'package:cii/models/notification.dart';
import 'package:cii/models/pdfexportrecords.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/services/notification_service.dart';
import 'package:cii/services/background_notification_service.dart';
import 'package:cii/controllers/notification_controller.dart';
import 'package:cii/view/settings/settings.dart';
import 'package:cii/theme.dart';
import 'package:cii/view/screen.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ColorAdapter());
  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(CommentAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(TagAdapter());
  Hive.registerAdapter(CompanyAdapter());
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(StatusAdapter());
  Hive.registerAdapter(SnagAdapter());
  Hive.registerAdapter(PdfExportRecordsAdapter());
  Hive.registerAdapter(NotificationTypeAdapter());
  Hive.registerAdapter(AppNotificationAdapter());
  // Hive.deleteBoxFromDisk('companies');

  // load user preferences
  AppTerminology.loadTerminologyPrefs();
  AppDateTimeFormat.loadDateTimePrefs();

  await Hive.openBox<Company>('companies');
  await Hive.openBox<Project>('projects');
  await Hive.openBox<Snag>('snags');
  
  // Initialize notification service
  await NotificationService().initialize();
  
  // Check for notifications on app start
  final notificationController = NotificationController();
  await notificationController.checkAndCreateNotifications();
  
  // Start background notification checks
  BackgroundNotificationService().startPeriodicChecks();


  runApp(const MainApp());
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
      }
    );
  }
}

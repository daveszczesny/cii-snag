import 'package:cii/adapters/color_adapter.dart';
import 'package:cii/adapters/priority_enum_adapter.dart';
import 'package:cii/models/category.dart';
import 'package:cii/models/comment.dart';
import 'package:cii/models/company.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/tag.dart';
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
  await Hive.openBox<Company>('companies');
  await Hive.openBox<Project>('projects');

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
      themeMode: ThemeMode.system,
      home: const Screen(),
    );
  }
}

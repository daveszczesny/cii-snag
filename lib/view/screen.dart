import 'package:cii/controllers/company_controller.dart';
import 'package:cii/models/company.dart';
import 'package:cii/view/company/company_create.dart';
import 'package:cii/view/notifications/notification.dart';
import 'package:cii/view/project/project_create.dart';
import 'package:cii/view/project/project_list.dart';
import 'package:cii/view/search/search.dart';
import 'package:cii/view/snag/snag_create.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


/*

This is the main screen of the app.
It contains a list of all the projects
and a bottom navigation bar to navigate between the different screens.

*/

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {

  late CompanyController companyController;

  int _index = 0;

  @override
  void initState() {
    super.initState();
    companyController = CompanyController(Hive.box<Company>('companies'));
  }

  static const List<Widget> _widgetOptions = <Widget>[
    ProjectListView(), // 0
    Search(), // 1
    Notifications(), // 2
    ProjectListView(), // 3
  ];

  void onItemTapped(int index) {
    if (index == 3) {
      // show modal bottm sheet for add project / quick add option
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return FractionallySizedBox(heightFactor: 0.3, child: _buildBottomSheetContent());
        }
      );
    } else { setState(() { _index = index; }); }
  }

  // Create Project or Snag (QUICK ADD) Bottom sheet
  Widget _buildBottomSheetContent() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const ImageIcon(
                  AssetImage(AppAssets.projectIcon),
                  size: 100,
                ),
                onPressed: () {
                  // Hide the bottom sheet
                  Navigator.pop(context);

                  // navigate to create project screen
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ProjectCreate())
                  );
                },
              ),
              const Text(
                AppStrings.project,
                style: TextStyle(fontSize: 14, fontFamily: 'Roboto', fontWeight: FontWeight.w300),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const ImageIcon(AssetImage(AppAssets.snagIcon), size: 100),
                onPressed: () {
                  // Hide the bottom sheet
                  Navigator.pop(context);

                  // navigate to create snag screen
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SnagCreate())
                  );
                }
              ),
              const Text(
                AppStrings.snag,
                style: TextStyle(fontSize: 14, fontFamily: 'Roboto', fontWeight: FontWeight.w300)
              )
            ],
          )
        ]
      )
    );
  }

  void onChange() {
    setState(() {});
  }

  void createDefaultCompany() {
    companyController.createCompany(
      name: 'Default Company'
    );
  }

  @override
  Widget build(BuildContext context) {

    if (companyController.getCompany() == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to CII',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                // two buttons. 1. to create a company. 2. to not make a company
                buildTextButton('Register your Company', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CompanyCreate(onChange: onChange))
                  );
                }),
                const SizedBox(height: 16),
                buildTextButton('Skip for now', () {
                  // create a default company
                  createDefaultCompany();
                  onChange();
                })
              ],
            )
          )
        )
      );
    } else {
       return Scaffold(
          body: Center(
            child: _widgetOptions.elementAt(_index),
          ),
          bottomNavigationBar: NavigationBar(
            height: AppSizing.bottomNavBarHeight,
            selectedIndex: _index,
            onDestinationSelected: onItemTapped,
            destinations: [
              NavigationDestination(icon: Icon(_index == 0 ? Icons.home_filled : Icons.home_outlined,),label: AppStrings.home),
              NavigationDestination(icon: Icon(_index == 1 ? Icons.search : Icons.search_outlined,),label: AppStrings.search),
              NavigationDestination(icon: Icon(_index == 2 ? Icons.notifications : Icons.notifications_outlined,),label: AppStrings.notifications),
              NavigationDestination(icon: Icon(_index == 3 ? Icons.add : Icons.add_outlined), label: AppStrings.add)
            ],
          ),
        );
    }
  }
}
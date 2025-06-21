
import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/category.dart';
import 'package:cii/models/status.dart';
import 'package:cii/services/pdf_exporter.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';

class ProjectExportCustomizer extends StatefulWidget {
  final SingleProjectController projectController;
  const ProjectExportCustomizer({super.key, required this.projectController});

  @override
  State<ProjectExportCustomizer> createState() => _ProjectExportCustomizerState();
}


/*

This widget is used to allow the user to customize the export of the project.
It allows the following:
- Image export quality
- Project Categories to include
- Snag statuses to include

 */

class _ProjectExportCustomizerState extends State<ProjectExportCustomizer> {

  late ValueNotifier<String> selectedQualityNotifier;
  late List<Category> categories;
  late Set<String> selectedCategories;
  final String uncategorizedLabel = 'Uncategorized';
  late Set<String> allCategories;

  List<Status> statuses = [
    Status.todo,
    Status.inProgress,
    Status.completed,
    Status.blocked
  ];
  late Set<String> selectedStatuses;

  @override
  void initState() {
    super.initState();
    selectedQualityNotifier = ValueNotifier<String>('High');

    // initialize the categories
    categories = widget.projectController.getCategories ?? [];
    allCategories = categories.map((c) => c.name).toSet();
    allCategories.add(uncategorizedLabel);
    // populate selectedCategories with the names of all categories
    selectedCategories = allCategories.toSet();

   // populate selectedStatuses with the names of all statuses
    selectedStatuses = statuses.map((status) => status.name).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Export Customization"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Customize your export settings for the project"),
              const SizedBox(height: 24.0),
              // Add customization options here
              buildCustomSegmentedControl(
                label: 'Photo Quality',
                options: ['Low', 'Medium', 'High'],
                selectedNotifier: selectedQualityNotifier
              ),

              const SizedBox(height: 24.0),

              if (categories.isNotEmpty) ... [

                const Divider(height: 20, thickness: 0.5, color: Colors.grey),
                const SizedBox(height: 8.0),

                const Text(
                  "Categories",
                  style: TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')
                ),
                const SizedBox(height: 6.0),
                const Text(
                  'Selected categories will be included in the export',
                  style: TextStyle(color: Color(0xFF333333), fontSize: 12, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
                const SizedBox(height: 8.0),
                
                // list of checkboxes for each category
                // a category does not have a isSelected property
                Row(
                  children: [
                    TextButton(onPressed: () {
                      setState(() {
                        selectedCategories.clear();
                      });
                    }, child: const Text('Deselect All')),
                    const Spacer(),
                    TextButton(onPressed: () {
                        setState(() {
                          selectedCategories = allCategories.toSet();
                        });
                      }, child: const Text('Select All'),
                    ),
                  ]
                ),
                const SizedBox(height:8.0),


                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...categories.map((category) => Row(
                      children: [
                        Expanded(child: Text(category.name, style: const TextStyle(fontSize: 15.0, fontFamily: 'Roboto'))),
                        Checkbox(
                          value: selectedCategories.contains(category.name),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedCategories.add(category.name);
                              } else {
                                selectedCategories.remove(category.name);
                              }
                            });
                          }
                        ),
                      ],
                    )),
                    // Add the uncategorized option
                    Row(
                      children: [
                        Expanded(child: Text(uncategorizedLabel, style: const TextStyle(fontSize: 15.0, fontFamily: 'Roboto'))),
                        Checkbox(
                          value: selectedCategories.contains(uncategorizedLabel),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedCategories.add(uncategorizedLabel);
                              } else {
                                selectedCategories.remove(uncategorizedLabel);
                              }
                            });
                          }
                        ),
                      ],
                    ),
                  ],
                )
              ],

              const Divider(height: 20, thickness: 0.5, color: Colors.grey),
              const SizedBox(height: 8.0),

              const Text(
                "Statuses",
                style: TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')
              ),
              const SizedBox(height: 6.0),
              const Text(
                'Selected statuses will be included in the export',
                style: TextStyle(color: Color(0xFF333333), fontSize: 12, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
              const SizedBox(height: 8.0),
              
              // list of checkboxes for each category
              // a category does not have a isSelected property
              Row(
                children: [
                    TextButton(onPressed: () {
                    setState(() {
                      selectedStatuses.clear();
                    });
                  }, child: const Text('Deselect All')),
                  const Spacer(),
                  TextButton(onPressed: () {
                      setState(() {
                        selectedStatuses = statuses.map((s) => s.name).toSet();
                      });
                    }, child: const Text('Select All'),
                  ),
                ]
              ),
              const SizedBox(height:8.0),


              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: statuses.map((status) {
                  return Row(
                    children: [
                      Expanded(child: Text(
                        status.name,
                        style: const TextStyle(fontSize: 15.0, fontFamily: 'Roboto'),
                      )),
                      Checkbox(
                        value: selectedStatuses.contains(status.name),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedStatuses.add(status.name);
                            } else {
                              selectedStatuses.remove(status.name);
                            }
                          });
                        }
                      ),
                    ],
                  );
                }).toList(),
              ),

              const SizedBox(height: 24.0),
              buildTextButton("Export to PDF", () async {
                await savePdfFile(
                  widget.projectController,
                  selectedQualityNotifier.value,
                  selectedCategories.toList(),
                  selectedStatuses.toList()
                  );

                  Navigator.of(context).pop();
              }),
              const SizedBox(height: 24.0),
            ]
          ),
        ),
    )
    );
  }
}
import 'package:cii/models/category.dart';
import 'package:cii/models/status.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/services/tier_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ProjectExportCustomizerBase extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectExportCustomizerBase({super.key, required this.projectId});
}


abstract class ProjectExportCustomizerBaseState<T extends ProjectExportCustomizerBase> extends ConsumerState<T> {

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
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final project = ProjectService.getProject(ref, widget.projectId);

    // initialize the categories
    categories = project.createdCategories ?? [];
    allCategories = categories.map((c) => c.name).toSet();
    allCategories.add(uncategorizedLabel);

    // populate selected categories with the names of all categories
    selectedCategories = allCategories.toSet();

    // populated selected statuses with the names of all statuses
    selectedStatuses = statuses.map((s) => s.name).toSet();
  }

  // Abstracts
  String get title;
  List<Widget> buildCustomOptions();
  Widget buildExportButton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Customize your export settings"),
              const SizedBox(height: 24.0),
              ...buildCustomOptions(),

              if (TierService.instance.canPdfCustomizer) ... [
                if (categories.isNotEmpty) ... buildCategorySection(),
                ... buildStatusSection(),
              ] else ... [
                const Text(
                  'Upgrade to Premium to customize categories and statuses in your export',
                  style: TextStyle(color: Colors.red, fontSize: 14.0, fontWeight: FontWeight.w400)
                ),
              ],
              const SizedBox(height: 24.0),
              buildExportButton(),
            ]
          )
        )
      )
    );
  }

  List<Widget> buildCategorySection() {
    return [
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
    ];
  }

  List<Widget> buildStatusSection() {
    return [
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
    ];
  }

}
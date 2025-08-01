import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/services/pdf_exporter.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/project/export/project_csv_export_customizer.dart';
import 'package:cii/view/project/export/project_export_customizer.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProjectExport extends StatefulWidget {
  final SingleProjectController projectController;
  const ProjectExport({super.key, required this.projectController});

  @override
  State<ProjectExport> createState() => _ProjectExportState();
}

/*

Project Export Page
Supports PDF, and Excel functionality
This page shows previous exports of the project and will
allow customization of the export format for pdf and excel.

*/

class _ProjectExportState extends State<ProjectExport> with SingleTickerProviderStateMixin {

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  Widget buildExporterTab(String type) {
    // Will contain an option to export the project in the specified format
    // this will bring user to further customization options
    // under it will list previous exports of the project
    if (type == "PDF") {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextButton("Export to $type", () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectExportCustomizer(projectController: widget.projectController))
              );
            }), const SizedBox(height: 24.0),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Previous Exports", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.0))
                ), Expanded(child: Divider()),
              ]
            ), const SizedBox(height: 24.0),
            // show previous exports as a list
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: widget.projectController.getPdfExportRecordsListenable(),
                builder: (context, pdfExports, _) {
                  if (pdfExports.isEmpty) { return const Center(child: Text('No previous exports found,')); }
                  // Sort by export date, newest first
                  final sortedExports = List.from(pdfExports)..sort((a, b) => b.exportDate.compareTo(a.exportDate));
                  return ListView.builder(
                    itemCount: sortedExports.length,
                    itemBuilder: (context, index) {
                      final record = sortedExports[index];
                      return Dismissible(
                        key: Key(record.uuid),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm"),
                                content: const Text("Are you sure you want to delete this export?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
                                  TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Delete")),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          widget.projectController.deletePdfExportRecord(record);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Export deleted'), duration: Duration(seconds: 2))
                          );
                        },
                        child: ListTile(
                          leading: const Icon(Icons.picture_as_pdf),
                          title: Text(record.fileName),
                          subtitle: Text(
                            '${DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(record.exportDate)} - ${formatFileSize(record.fileSize)}'
                          ),
                          trailing: const Icon(Icons.open_in_new),
                          onTap: () async {
                            try {
                              await openPdfFromRecord(record);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Could not open PDF. ${e.toString()}'))
                              );
                            }
                          }
                        ),
                      );
                    }
                  );
                }
              )
            )
          ]
        )
      );
    } else if (type == "CSV") {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextButton("Export to $type", () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectCsvExportCustomizer(projectController: widget.projectController))
              );
            }), const SizedBox(height: 24.0),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Previous Exports", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.0))
                ), Expanded(child: Divider()),
              ]
            )
          ],
        )
      );
    } else {
      return const Center(child: Text('Unknown Export Type'));
    }
  }


  @override
  Widget build(BuildContext context) {


    const List<Widget> tabs = [
      Tab(text: 'PDF'),
      Tab(text: 'CSV')
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Export ${widget.projectController.getName!}"),
      ),
      body: Column(
        children: [
          TabBar(
            controller: tabController,
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            tabs: tabs,
          ),
          ValueListenableBuilder(
            valueListenable: AppTerminology.version,
            builder: (context, _, __) {
              return Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    buildExporterTab('PDF'),
                    buildExporterTab('CSV'),
                  ]
                )
              );
            }
          )
        ]
      )
    );
  }
}
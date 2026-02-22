import 'dart:async';

import 'package:cii/models/csvexportrecords.dart';
import 'package:cii/models/pdfexportrecords.dart';
import 'package:cii/models/project.dart';
import 'package:cii/services/csv_exporter.dart';
import 'package:cii/services/pdf_exporter.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/services/tier_service.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/project/export/project_csv_export_customizer.dart';
import 'package:cii/view/project/export/project_export_customizer.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ProjectExport extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectExport({super.key, required this.projectId});

  @override
  ConsumerState<ProjectExport> createState() => _ProjectExportState();
}

/*

Project Export Page
Supports PDF, and Excel functionality
This page shows previous exports of the project and will
allow customization of the export format for pdf and excel.

*/

class _ProjectExportState extends ConsumerState<ProjectExport> with SingleTickerProviderStateMixin {

  late TabController tabController;


  bool _highlightFirstItem = false;
  Timer? _highlightTimer;

  int _pdfExportsCount = 0;
  int _csvExportsCount = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    super.dispose();
  }

  void _checkForNewExport() {
    setState(() => _highlightFirstItem = true);
    _highlightTimer = Timer(const Duration(seconds: 3), () {
      if(mounted) setState(() => _highlightFirstItem = false);
    });
  }

  Widget buildExporterTab(Project project, String type) {
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
              _pdfExportsCount = project.pdfExportRecords?.length ?? 0;
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectExportCustomizer(projectId: project.id!))
              );
              final updatedProject = ProjectService.getProject(ref, widget.projectId);
              if ((updatedProject.pdfExportRecords?.length ?? 0) > _pdfExportsCount) {
                _checkForNewExport();
              }
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
              child: Consumer(
                builder: (context, ref, _) {
                  final currentProject = ProjectService.getProject(ref, widget.projectId);
                  final pdfExports = currentProject.pdfExportRecords ?? [];
                  if (pdfExports.isEmpty) { return const Center(child: Text('No previous exports found,')); }
                  // Sort by export date, newest first
                  final sortedExports = List.from(pdfExports)..sort((a, b) => b.exportDate.compareTo(a.exportDate));
                  return ListView.builder(
                    itemCount: sortedExports.length,
                    itemBuilder: (context, index) {
                      final record = sortedExports[index];
                      final isHighlighted = _highlightFirstItem && index == 0;
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
                          final updatedRecords = List<PdfExportRecords>.from(currentProject.pdfExportRecords ?? []);
                          updatedRecords.removeWhere((r) => r.uuid == record.uuid);
                          final updatedProject = currentProject.copyWith(pdfExportRecords: updatedRecords);
                          ProjectService.updateProject(ref, updatedProject);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Export deleted'), duration: Duration(seconds: 2))
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: isHighlighted ? Colors.blue.withOpacity(0.1) : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
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
              if (!TierService.instance.canExportCsv) {
                // Show snack bar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV export is not available in the free tier. Please upgrade to premium to unlock this feature.'))
                );
                return;
              }

              _csvExportsCount = project.csvExportRecords?.length ?? 0;
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectCsvExportCustomizer(projectId: widget.projectId)),
              );

              final updatedProject = ProjectService.getProject(ref, widget.projectId);
              if ((updatedProject.csvExportRecords?.length ?? 0) > _pdfExportsCount) {
                _checkForNewExport();
              }
            },
            enabled: TierService.instance.canExportCsv,
            ),
            const SizedBox(height: 24.0),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Previous Exports", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.0))
                ), 
                Expanded(child: Divider()),
              ]
            ), 
            const SizedBox(height: 24.0),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final currentProject = ProjectService.getProject(ref, widget.projectId);
                  final csvExports = currentProject.csvExportRecords ?? [];
                  if (csvExports.isEmpty) { 
                    return const Center(child: Text('No previous exports found')); 
                  }
                  final sortedExports = List.from(csvExports)..sort((a, b) => b.exportDate.compareTo(a.exportDate));
                  return ListView.builder(
                    itemCount: sortedExports.length,
                    itemBuilder: (context, index) {
                      final record = sortedExports[index];
                      final isHighlighted = _highlightFirstItem && index == 0;
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
                          final updatedRecords = List<CsvExportRecords>.from(currentProject.csvExportRecords ?? []);
                          updatedRecords.removeWhere((r) => r.uuid == record.uuid);
                          final updatedProject = currentProject.copyWith(csvExportRecords: updatedRecords);
                          ProjectService.updateProject(ref, updatedProject);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Export deleted'), duration: Duration(seconds: 2))
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: isHighlighted ? Colors.blue.withOpacity(0.1) : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.table_chart),
                            title: Text(record.fileName),
                            subtitle: Text(
                              '${DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(record.exportDate)} - ${formatFileSize(record.fileSize)}'
                            ),
                            trailing: const Icon(Icons.open_in_new),
                            onTap: () async {
                              try {
                                await openCsvFromRecord(record);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not open CSV. ${e.toString()}'))
                                );
                              }
                            }
                          ),
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
    } else {
      return const Center(child: Text('Unknown Export Type'));
    }
  }


  @override
  Widget build(BuildContext context) {
    final Project project = ProjectService.getProject(ref, widget.projectId);
    final List<Widget> tabs = [
      const Tab(text: 'PDF'),
      Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('CSV'),
            if (!TierService.instance.canExportCsv) ...[
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 16, color: Colors.amber),
            ],
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Export ${[project.name]}"),
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
                    buildExporterTab(project, 'PDF'),
                    buildExporterTab(project, 'CSV'),
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
import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/category.dart';
import 'package:cii/models/status.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class ProjectAnalytics extends StatefulWidget {
  final SingleProjectController projectController;

  const ProjectAnalytics({super.key, required this.projectController});

  @override
  State<ProjectAnalytics> createState() => _ProjectAnalyticsState();
}


class _ProjectAnalyticsState extends State<ProjectAnalytics> {

  Widget statusAnalyticsWidget(BuildContext context, totalSnags) {
    if (totalSnags == 0) {
      return const SizedBox.shrink();
    }
    final totalCompleted = widget.projectController.getTotalSnagsByStatus(Status.completed);
    final totalNew = widget.projectController.getTotalSnagsByStatus(Status.todo);
    final totalOnHold = widget.projectController.getTotalSnagsByStatus(Status.blocked);
    final totalInProgress = widget.projectController.getTotalSnagsByStatus(Status.inProgress);

    final totalSections = totalCompleted + totalNew + totalOnHold + totalInProgress;
    if (totalSections == 0) {
      return const SizedBox.shrink();
    }

    final Map<String, double> dataMap = {
      'Completed': totalCompleted.toDouble(),
      'New': totalNew.toDouble(),
      'On Hold': totalOnHold.toDouble(),
      'In Progress': totalInProgress.toDouble(),
    };

    final List<Color> colorList = [
      Colors.green.withOpacity(0.5),
      Colors.blue.withOpacity(0.5),
      Colors.red.withOpacity(0.5),
      Colors.yellow.withOpacity(0.5),
    ];

    // final totalCompletedPercentage = (totalCompleted / totalSnags * 100).toInt();
    // final totalNewPercentage = (totalNew / totalSnags * 100).toInt();
    // final totalOnHoldPercentage = (totalOnHold / totalSnags * 100).toInt();
    // final totalInProgressPercentage = (totalInProgress / totalSnags * 100).toInt();

    return ExpansionTile(
      initiallyExpanded: true,
      shape: const RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.zero,
      ),
      collapsedShape: const RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.zero,
      ),
      title: const Text('Status Analytics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
      children: [
        Align(alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Text('To do: $totalNewPercentage%', style: const TextStyle(fontSize: 14)),
              // const SizedBox(height: 8),
              // Text('In progress: $totalInProgressPercentage%', style: const TextStyle(fontSize: 14)),
              // const SizedBox(height: 8),
              // Text('On Hold: $totalOnHoldPercentage%', style: const TextStyle(fontSize: 14)),
              // const SizedBox(height: 8),
              // Text('Completed: $totalCompletedPercentage%', style: const TextStyle(fontSize: 14)),
              // const SizedBox(height: 24),
              PieChart(
                dataMap: dataMap,
                colorList: colorList,
                chartRadius: MediaQuery.of(context).size.width / 3.2,
                chartType: ChartType.ring,
                ringStrokeWidth: 32,
                legendOptions: const LegendOptions(
                  showLegendsInRow: true,
                  legendPosition: LegendPosition.top,
                  showLegends: true,
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValueBackground: true,
                  showChartValues: true,
                  showChartValuesOutside: true,
                  showChartValuesInPercentage: true,
                  decimalPlaces: 0,
                  chartValueStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.black),
                ),
              ),
              const SizedBox(height: 32),
            ],
          )
        )
      ],
    );
  }

  Widget categoryAnalyticsWidget(BuildContext context, totalSnags) {
    if (totalSnags == 0) {
      return const SizedBox.shrink();
    }
    final categories = (widget.projectController.getCategories ?? []).toList();
    if (categories.isEmpty) { 
      return const SizedBox.shrink();
    }
    final Map<String, double> categoryCounts = {};
    for (var cat in categories) {
      final snagList = widget.projectController.getSnagsByCategory(cat.name).toList();;
      final count = snagList.length;
      categoryCounts[cat.name] = count.toDouble();
    }

    final noCategorySnags = widget.projectController.getSnagsWithNoCategory().toList();
    if (noCategorySnags.isNotEmpty) {
      categoryCounts['No Category'] = noCategorySnags.length.toDouble();
      categories.add(
        Category(
          name: 'No Category',
          color: Colors.blue.withOpacity(0.5),
        )
      );
    }

    // Sort categories by count
    final sortedCategories = categoryCounts.entries.toList()
    ..sort((a, b) {
      if (a.key == 'No Category') return 1; // a goes after b
      if (b.key == 'No Category') return -1; // b goes after a
      return b.value.compareTo(a.value); // sort by count descending
    });

    final colorList = sortedCategories
      .where((entry) => entry.value > 0)
      .map((entry) => categories.firstWhere((cat) => cat.name == entry.key).color.withOpacity(0.5))
      .toList();

    
    // find the number of snags in each status for each category
    Map<String, List<int>> categoryStatusCounts = {};
    for (var entry in sortedCategories) {
      final categoryName = entry.key;
      final count = entry.value.toInt();
      var snagsInCategory = [];
      if (count > 0) {
        
        if (categoryName == 'No Category') {
          snagsInCategory = noCategorySnags;
        } else {
          snagsInCategory = widget.projectController.getSnagsByCategory(categoryName);
        }
        final statusCounts = {
          'todo': snagsInCategory.where((snag) => snag.status.name == Status.todo.name).length,
          'inProgress': snagsInCategory.where((snag) => snag.status.name == Status.inProgress.name).length,
          'blocked': snagsInCategory.where((snag) => snag.status.name == Status.blocked.name).length,
          'completed': snagsInCategory.where((snag) => snag.status.name == Status.completed.name).length,
        };
        categoryStatusCounts[categoryName] = [
          statusCounts['todo'] ?? 0,
          statusCounts['inProgress'] ?? 0,
          statusCounts['blocked'] ?? 0,
          statusCounts['completed'] ?? 0,
        ];
      }
    }

    return ExpansionTile(
      initiallyExpanded: true,
      title: const Text('Category Analytics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 16),
              PieChart(
                dataMap: Map.fromEntries(
                  sortedCategories.where((entry) => entry.value > 0),
                ),
                colorList: colorList,
                chartRadius: MediaQuery.of(context).size.width / 3.2,
                chartType: ChartType.ring,
                ringStrokeWidth: 32,
                legendOptions: const LegendOptions(
                  showLegendsInRow: true,
                  legendPosition: LegendPosition.top,
                  showLegends: true,
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValueBackground: true,
                  showChartValues: true,
                  showChartValuesOutside: true,
                  showChartValuesInPercentage: true,
                  decimalPlaces: 0,
                  chartValueStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.black),
                ),
              ),
              const SizedBox(height: 32),

              ...sortedCategories.where((entry) => entry.value > 0).map((entry) {
                final categoryName = entry.key;
                final count = entry.value;

                final statusCounts = categoryStatusCounts[categoryName] ?? [0, 0, 0, 0];
                final todoPercent = statusCounts[0] / count;
                final inProgressPercent = statusCounts[1] / count;
                final onHoldPercent = statusCounts[2] / count;
                final completedPercent = statusCounts[3] / count;


                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(categoryName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color.fromARGB(255, 255, 255, 255), width: 0.4),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.transparent,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double width = constraints.maxWidth;
                            double start = 0;

                            List<Widget> bars = [];

                            void addBar(double percent, Color color) {
                              if (percent > 0) {
                                final barWidth = width * percent;
                                bars.add(Positioned(
                                  left: start,
                                  child: Container(
                                    width: barWidth,
                                    height: 8,
                                    color: color,
                                  ),
                                ));
                                start += barWidth;
                              }
                            }
                            // Order: green (completed), yellow (in progress), white (todo), red (on hold)
                            addBar(completedPercent, Colors.green);
                            addBar(inProgressPercent, Colors.yellow);
                            addBar(todoPercent, Colors.grey[300]!);
                            addBar(onHoldPercent, Colors.red);

                            return Stack(children: bars);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ]
                );
              }),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSnags = widget.projectController.getTotalSnags();

    final DateTime createdDate = widget.projectController.getDateCreated!;
    final DateTime? dueDate = widget.projectController.getDueDate;
    final DateTime today = DateTime.now();

    final int daysSinceCreated = today.difference(createdDate).inDays;
    final int? daysUntilDue = dueDate?.difference(today).inDays;

    final int? daysDelta = dueDate?.difference(createdDate).inDays;


    return ExpansionTile(
      initiallyExpanded: false,
      title: const Text('Project Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.left),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text('Total ${AppStrings.snags()}: $totalSnags', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              // if daysToCompletion is not null then create a linear progress bar with the percentage of days completed

              if (daysUntilDue != null && daysDelta != null) ... [
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: daysSinceCreated / (daysDelta > 0 ? daysDelta : 1),
                  backgroundColor: Colors.grey[300],
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                Text('Deadline in $daysUntilDue days', style: const TextStyle(fontSize: 14)),
              ] else ... [
                const SizedBox(height: 8),
                const Text('No due date set', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
              const SizedBox(height: 18),
              statusAnalyticsWidget(context, totalSnags),
              const SizedBox(height: 8),
              categoryAnalyticsWidget(context, totalSnags),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
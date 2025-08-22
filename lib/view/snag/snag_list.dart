import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/controllers/snag_controller.dart';
import 'package:cii/models/status.dart';
import 'package:cii/view/snag/snag_card_widget.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';

class SnagList extends StatefulWidget {
  final SingleProjectController projectController;

  const SnagList({super.key, required this.projectController});

  @override
  State<SnagList> createState() => _SnagListState();
}

class _SnagListState extends State<SnagList> with SingleTickerProviderStateMixin{

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<SnagController> sorted(List<SnagController> snagList) {
    snagList.sort((a, b) {
      String aCat = (a.categories.isNotEmpty) ? a.categories[0].name : '-';
      String bCat = (b.categories.isNotEmpty) ? b.categories[0].name : '-';

      // Put uncategorized last
      if (aCat == '-' && bCat != '-') return 1;
      if (bCat == '-' && aCat != '-') return -1;

      // Sort by category name
      int catCompare = aCat.compareTo(bCat);
      if (catCompare != 0) return catCompare;

      // Custom status order
      final List<String> statusOrder = [Status.todo.name, Status.inProgress.name, Status.blocked.name, Status.completed.name];
      int aIndex = statusOrder.indexOf(a.status.name);
      int bIndex = statusOrder.indexOf(b.status.name);

      if (aIndex == -1) aIndex = statusOrder.length;
      if (bIndex == -1) bIndex = statusOrder.length;

      return aIndex.compareTo(bIndex);
    });
    return snagList;
  }

  List<SnagController> filterSnags(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return sorted(widget.projectController.getSnagsByStatus(Status.todo));
      case 'in progress':
        return sorted(widget.projectController.getSnagsByStatus(Status.inProgress));
      case 'completed':
        return sorted(widget.projectController.getSnagsByStatus(Status.completed));
      case 'blocked':
      case 'on hold':
        return sorted(widget.projectController.getSnagsByStatus(Status.blocked));
      default:
        return sorted(widget.projectController.getAllSnags());
    }
  }

  void _onStatusChanged() {
    setState(() {});
    widget.projectController.saveProject();
  }

  Widget buildSnagList(String status) {
    final List<SnagController> snags = filterSnags(status);
    if (snags.isEmpty) {
      return Center(child: Text(AppStrings.noSnagsFound()));
    }

    return ListView.builder(
      itemCount: snags.length,
      itemBuilder: (context, index) {
        final SnagController snag = snags[index];
        return SnagCardWidget(
          projectController: widget.projectController,
          snagController: snag,
          onStatusChanged: _onStatusChanged,
        );
      }
    );
  }

  // bar at the top
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: AppStrings.all),
              Tab(text: AppStrings.statusTodo),
              Tab(text: AppStrings.statusInProgress),
              Tab(text: AppStrings.statusCompleted),
              Tab(text: AppStrings.statusBlocked)
            ]
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                  buildSnagList(AppStrings.all),
                  buildSnagList(Status.todo.name),
                  buildSnagList(Status.inProgress.name),
                  buildSnagList(Status.completed.name),
                  buildSnagList(Status.blocked.name),
              ]
            )
          )
        ],
      )
    );
  }
}
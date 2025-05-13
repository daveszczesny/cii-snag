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

  List<SnagController> filterSnags(String status) {
    // TODO: clean this up
    switch (status.toLowerCase()) {
      case 'to do':
        return widget.projectController.getSnagsByStatus(Status.todo);
      case 'in progress':
        return widget.projectController.getSnagsByStatus(Status.inProgress);
      case 'completed':
        return widget.projectController.getSnagsByStatus(Status.completed);
      case 'blocked':
      case 'on hold':
      case 'onhold':
        return widget.projectController.getSnagsByStatus(Status.blocked);
      default:
        return widget.projectController.getAllSnags();
    }
  }

  void _onStatusChanged() {
    setState(() {});
    widget.projectController.saveProject();
  }

  Widget buildSnagList(String status) {
    final List<SnagController> snags = filterSnags(status);
    if (snags.isEmpty) {
      return const Center(child: Text('No snags found'));
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
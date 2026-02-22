import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/view/snag/snag_card_widget.dart';
import 'package:cii/view/utils/constants.dart';

class SnagList extends ConsumerStatefulWidget {
  final String projectId;

  const SnagList({super.key, required this.projectId});

  @override
  ConsumerState<SnagList> createState() => _SnagListState();
}

class _SnagListState extends ConsumerState<SnagList> with SingleTickerProviderStateMixin{

  late TabController _tabController;
  final Map<String, List<Snag>> _cachedSnagOrder = {};

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

  void _cacheInitialOrder() {
    final List<Snag> snags = ProjectService.getSnags(ref, widget.projectId)
      .map((s) => s)
      .toList();
    _cachedSnagOrder["all"] = sorted(snags);
  }

  List<Snag> sorted(List<Snag> snagList) {
    snagList.sort((a, b) {
      String aCat = (a.categories != null && a.categories!.isNotEmpty) ? a.categories![0].name : '-';
      String bCat = (b.categories != null && b.categories!.isNotEmpty) ? b.categories![0].name : '-';

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

  List<Snag> filterSnags(String status) {
    final List<Snag> snags = ProjectService.getSnags(ref, widget.projectId);

    if (status.toLowerCase() != "all") {
      return sorted(snags.where((s) => s.status.name == status)
        .map((s) => s)
        .toList());
    }

    List<Snag> orderedSnags = [];
    List<Snag> allSnags = snags.map((s) => s).toList();

    if (_cachedSnagOrder["all"] != null) {
      for (Snag cachedSnag in _cachedSnagOrder["all"]!) {
        final matchingSnags = allSnags.where((s) => s.uuid == cachedSnag.uuid);
        if (matchingSnags.isNotEmpty) {
          orderedSnags.add(matchingSnags.first);
        }
      }
    }

    for (Snag snag in allSnags) {
      if (!orderedSnags.any((s) => s.uuid == snag.uuid)) {
        orderedSnags.add(snag);
      }
    }
    return orderedSnags;
  }

  void _onStatusChanged() {
    setState(() {});
    // TODO - Is this correct to just not save here?
    // this will probably break even more things
    //widget.projectController.saveProject();
  }

  Widget buildSnagList(String status) {
    final List<Snag> snags = filterSnags(status);
    if (snags.isEmpty) {
      return Center(child: Text(AppStrings.noSnagsFound()));
    }

    return ListView.builder(
      itemCount: snags.length,
      itemBuilder: (context, index) {
        final Snag snag = snags[index];
        return SnagCardWidget(
          projectId: widget.projectId,
          snagId: snag.uuid,
          onStatusChanged: _onStatusChanged,
        );
      }
    );
  }

  // bar at the top
  @override
  Widget build(BuildContext context){
    _cacheInitialOrder();

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

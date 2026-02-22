import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/models/snag.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SnagNotifier extends StateNotifier<List<Snag>> {
  SnagNotifier() : super([]) {
    _loadSnags();
  }

  Box<Snag> get _box => Hive.box<Snag>('snags');

  void _loadSnags() {
    state = _box.values.toList();
  }

  void addSnag(Snag snag) {
    _box.put(snag.id, snag);
    state = [...state, snag];
  }

  void updateSnag(Snag snag) {
    _box.put(snag.id, snag);
    state = [
      for (final s in state)
        if (s.id == snag.id) snag else s
    ];
  }

  void deleteSnag(String snagId) {
    _box.delete(snagId);
    state = state.where((s) => s.id != snagId).toList();
  }

  List<Snag> getSnagsByProject(String projectId) {
    return state.where((s) => s.projectId == projectId).toList();
  }
}

final snagProvider = StateNotifierProvider<SnagNotifier, List<Snag>>(
  (ref) => SnagNotifier(),
);

// Filtered snag providers
final snagsByProjectProvider = Provider.family<List<Snag>, String>((ref, projectId) {
  final snags = ref.watch(snagProvider);
  return snags.where((s) => s.projectId == projectId).toList();
});

final singleSnagProvider = Provider.family<Snag?, String>((ref, snagId) {
  final snags = ref.watch(snagProvider);
  try {
    return snags.firstWhere((s) => s.id == snagId);
  } catch (e) {
    return null;
  }
});

import 'package:cii/models/snag.dart';
import 'package:cii/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final singleSnagProvider = Provider.family<Snag?, String>((ref, snagId) {
  final snags = ref.watch(snagProvider);
  try {
    return snags.firstWhere((s) => s.uuid == snagId);
  } catch (e) {
    return null;
  }
});


class SingleSnagNotifier extends StateNotifier<Snag?> {
  final Ref ref;

  SingleSnagNotifier(Snag? snag, this.ref) : super(snag);

  void updateSnag(Map<String, dynamic> updates) {
    if (state == null) return;

    if (updates.containsKey("name")) state!.name = updates["name"];
    if (updates.containsKey("description")) state!.description = updates["description"];
    if (updates.containsKey("location")) state!.location = updates["location"];
    if (updates.containsKey("assignee")) state!.assignee = updates["assignee"];
    if (updates.containsKey("priority")) state!.priority = updates["priority"];
    if (updates.containsKey("status")) state!.status = updates["status"];
    if (updates.containsKey("dueDate")) state!.dueDate = updates["dueDate"];

    state!.lastModified = DateTime.now();
    state = state; // trigger state change
    ref.read(snagProvider.notifier).updateSnag(state!);
  }
}
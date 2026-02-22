import 'package:cii/models/snag.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/providers/providers.dart';

class SnagService {

  static Snag getSnag(WidgetRef ref, String snagId) {
    return ref.watch(singleSnagProvider(snagId))!;
  }

  static void addSnag(WidgetRef ref, Snag snag) {
    ref.read(snagProvider.notifier).addSnag(snag);

    ref.read(projectProvider.notifier).incrementSnagCount(snag.projectId!);
  }

  static void updateSnag(WidgetRef ref, Snag snag) {
    ref.read(snagProvider.notifier).updateSnag(snag);
  }

  static void deleteSnag(WidgetRef ref, String snagId) {
    ref.read(snagProvider.notifier).deleteSnag(snagId);
  }

  static List<Snag> getSnagsByProject(WidgetRef ref, String projectId) {
    return ref.watch(snagsByProjectProvider(projectId));
  }


  // DEBUG FUNCTIONS
  static void logSnagAttributes(WidgetRef ref, String snagId) {
    final Snag snag = getSnag(ref, snagId);
    print('=== SNAG ATTRIBUTES ===');
    print('uuid: ${snag.uuid}');
    print('id: ${snag.id}');
    print('projectId: ${snag.projectId}');
    print('name: ${snag.name}');
    print('description: ${snag.description}');
    print('location: ${snag.location}');
    print('assignee: ${snag.assignee}');
    print('status: ${snag.status.name}');
    print('priority: ${snag.priority.name}');
    print('dateCreated: ${snag.dateCreated}');
    print('dateClosed: ${snag.dateClosed}');
    print('dateCompleted: ${snag.dateCompleted}');
    print('dueDate: ${snag.dueDate}');
    print('finalRemarks: ${snag.finalRemarks}');
    print('imagePaths: ${snag.imagePaths}');
    print('annotatedImagePaths: ${snag.annotatedImagePaths}');
    print('categories: ${snag.categories?.map((c) => c.name).toList()}');
    print('tags: ${snag.tags?.map((t) => t.name).toList()}');
    print('comments: ${snag.comments?.length ?? 0} comments');
    print('=======================');
  }
}
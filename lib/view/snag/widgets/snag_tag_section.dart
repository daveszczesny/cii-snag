import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/services/snag_service.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnagTagSection extends ConsumerWidget {
  final Project project;
  final Snag snag;
  final VoidCallback? onChanged;
  
  const SnagTagSection({
    super.key,
    required this.project,
    required this.snag,
    this.onChanged
  });


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ObjectSelector(
          label: AppStrings.tag,
          pluralLabel: AppStrings.tags,
          hint: AppStrings.tagHint(),
          options: project.createdTags ?? [],
          getName: (tag) => tag.name,
          getColor: (tag) => tag.color,
          allowMultiple: false,
          onCreate: (name, color) {
            if (name.isEmpty || name.trim().isEmpty) return;
              final updatedProject = project.copyWith(
                createdTags: [
                  Tag(name: capitilize(name), color: color),
                  ...project.createdTags ?? []
                ]
              );
              ProjectService.updateProject(ref, updatedProject);
              onChanged?.call();
          },
          onSelect: (tag) {
            if (!isListNullorEmpty(snag.tags) && snag.tags!.where((t) => t.name == tag.name).toList().isNotEmpty) {
              final Snag updatedSnag = snag.copyWith(
                tags: []
              );
              SnagService.updateSnag(ref, updatedSnag);
              onChanged?.call();
            } else {
              final Snag updatedSnag = snag.copyWith(
                tags: [tag]
              );
              SnagService.updateSnag(ref, updatedSnag);
              onChanged?.call();
              ;
            }
          },
          hasColorSelector: true,
          selectedItems: snag.tags,
        ),
      ],
    );
  }
}
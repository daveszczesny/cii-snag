import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/services/snag_service.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cii/models/category.dart';

class SnagCategorySection extends ConsumerWidget {
  final Project project;
  final Snag snag;
  final VoidCallback? onChanged;
  
  const SnagCategorySection({
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
          label: AppStrings.category,
          pluralLabel: AppStrings.categories,
          hint: AppStrings.categoryHint(),
          options: project.createdCategories ?? [],
          getName: (cat) => cat.name,
          getColor: (cat) => cat.color,
          allowMultiple: false,
          onCreate: (name, color) {
            if (name.isEmpty || name.trim().isEmpty) return;
              final updatedProject = project.copyWith(
                createdCategories: [
                  Category(name: capitilize(name), color: color),
                  ...project.createdCategories ?? []
                ]
              );
              ProjectService.updateProject(ref, updatedProject);
              onChanged?.call();
          },
          onSelect: (cat) {
            if (!isListNullorEmpty(snag.categories) && snag.categories!.where((c) => c.name == cat.name).toList().isNotEmpty) {
              final Snag updatedSnag = snag.copyWith(
                categories: []
              );
              SnagService.updateSnag(ref, updatedSnag);
              onChanged?.call();
            } else {
              final Snag updatedSnag = snag.copyWith(
                categories: [cat]
              );
              SnagService.updateSnag(ref, updatedSnag);
              onChanged?.call();
              ;
            }
          },
          hasColorSelector: true,
          selectedItems: snag.categories,
        ),
      ],
    );
  }
}

import 'package:cii/utils/colors/app_colors.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'status.g.dart';

@HiveType(typeId: 1)
class Status extends HiveObject {

  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final String name;

  @HiveField(2)
  Color? color;

  Status({
    String? uuid,
    required this.name,
    this.color,
  })
  : uuid = uuid ?? const Uuid().v4();

  // Create Statues
  static final Status todo = Status(
    name: AppStrings.statusTodo,
    color: AppColors.lightTodo
  );

  static final Status inProgress = Status(
    name: AppStrings.statusInProgress,
    color: AppColors.lightInProgress
  );

  static final Status completed = Status(
    name: AppStrings.statusCompleted,
    color: AppColors.lightCompleted
  );

  static final Status blocked = Status(
    name: AppStrings.statusBlocked,
    color: AppColors.lightBlocked
  );

  static final List<Status> values = [
    todo,
    inProgress,
    completed,
    blocked,
  ];

  static Status? getStatus(String name) {
    switch (name.toLowerCase()) {
      case 'todo':
      case 'to do':
        Status todo = Status.todo;
        return todo;
      case 'in progress':
      case 'inprogress':
        Status inProgress = Status.inProgress;
        return inProgress;
      case 'completed':
        Status completed = Status.completed;
        return completed;
      case 'blocked':
      case 'on hold':
      case 'onhold':
        Status blocked = Status.blocked;
        return blocked;
      default:
        Status defaultStatus = Status.todo;
        return defaultStatus;

    }
  }

}
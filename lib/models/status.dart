
import 'package:cii/utils/colors/status_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    name: 'To Do',
  );

  static final Status inProgress = Status(
    name: 'In Progress',
  );

  static final Status completed = Status(
    name: 'Completed',
  );

  static final Status blocked = Status(
    name: 'On Hold',
  );

  static final List<Status> values = [
    todo,
    inProgress,
    completed,
    blocked,
  ];

  static Status? getStatus(String name, BuildContext context) {
    final statusColors = Theme.of(context).extension<StatusColors>();
    switch (name.toLowerCase()) {
      case 'todo':
      case 'to do':
        Status todo = Status.todo;
        todo.color = statusColors?.todo;
        return todo;
      case 'in progress':
      case 'inprogress':
        Status inProgress = Status.inProgress;
        inProgress.color = statusColors?.inProgress;
        return inProgress;
      case 'completed':
        Status completed = Status.completed;
        completed.color = statusColors?.completed;
        return completed;
      case 'blocked':
        Status blocked = Status.blocked;
        blocked.color = statusColors?.blocked;
        return blocked;
      default:
        return null;

    }
  }

}
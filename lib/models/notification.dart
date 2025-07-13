import 'package:hive/hive.dart';

part 'notification.g.dart';

@HiveType(typeId: 10)
enum NotificationType {
  @HiveField(0)
  dueDateApproaching,
  @HiveField(1)
  overdue,
}

@HiveType(typeId: 11)
class AppNotification extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final NotificationType type;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String? snagId;

  @HiveField(6)
  final String? projectId;

  @HiveField(7)
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.snagId,
    this.projectId,
    this.isRead = false,
  });
}
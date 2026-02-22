import 'package:cii/models/project.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:hive/hive.dart';
import 'package:cii/models/notification.dart';
import 'package:cii/models/snag.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  late Box<AppNotification> _notificationBox;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    _notificationBox = await Hive.openBox<AppNotification>('notifications');
  }

  Future<void> checkSnagNotifications(List<Snag> snags) async {
    final now = DateTime.now();
    final approachingSnags = <Snag>[];
    final overdueSnags = <Snag>[];
    
    for (final snag in snags) {
      if (snag.dueDate != null) {
        final daysUntilDue = snag.dueDate!.difference(now).inDays;
        
        // Due date approaching (3 days)
        if (daysUntilDue <= 3 && daysUntilDue > 0) {
          approachingSnags.add(snag);
          await _createNotification(
            title: '${AppStrings.snag()} Due Soon',
            message: '${snag.name} is due in $daysUntilDue day${daysUntilDue == 1 ? '' : 's'}',
            type: NotificationType.dueDateApproaching,
            snagId: snag.uuid,
          );
        }

        // Overdue
        if (daysUntilDue < 0) {
          overdueSnags.add(snag);
          await _createNotification(
            title: 'Overdue ${AppStrings.snag()}',
            message: '${snag.name} is ${-daysUntilDue} day${-daysUntilDue == 1 ? '' : 's'} overdue',
            type: NotificationType.overdue,
            snagId: snag.uuid,
          );
        }
      }

      // No update reminder (7 days since last modified)
      // if (snag.lastModified != null) {
      //   final daysSinceUpdate = now.difference(snag.lastModified!).inDays;
      //   if (daysSinceUpdate >= 7) {
      //     await _createNotification(
      //       title: '${AppStrings.snag()} Needs Update',
      //       message: '${snag.name} hasn\'t been updated in $daysSinceUpdate days',
      //       type: NotificationType.noUpdate,
      //       snagId: snag.uuid,
      //     );
      //   }
      // }
    }
    
    // Create summary notifications for multiple snags
    if (approachingSnags.length > 1) {
      await _createNotification(
        title: 'Multiple ${AppStrings.snags()} Due Soon',
        message: '${approachingSnags.length} ${AppStrings.snags().toLowerCase()} are approaching their due dates',
        type: NotificationType.dueDateApproaching,
      );
    }

    if (overdueSnags.length > 1) {
      await _createNotification(
        title: 'Multiple Overdue ${AppStrings.snags()}',
        message: '${overdueSnags.length} ${AppStrings.snags().toLowerCase()} are overdue and need attention',
        type: NotificationType.overdue,
      );
    }
  }

  Future<void> _createNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? snagId,
    String? projectId,
  }) async {
    final id = const Uuid().v4();
    
    // Check if similar notification already exists (avoid spam)
    final existing = _notificationBox.values.where((n) => 
      n.snagId == snagId && n.type == type && !n.isRead &&
      DateTime.now().difference(n.createdAt).inHours < 24
    ).toList();
    
    if (existing.isEmpty) {
      final notification = AppNotification(
        id: id,
        title: title,
        message: message,
        type: type,
        createdAt: DateTime.now(),
        snagId: snagId,
        projectId: projectId,
      );
      
      await _notificationBox.put(id, notification);
      await _showPushNotification(title, message, id.hashCode);
    }
  }

  Future<void> _showPushNotification(String title, String body, int id) async {
    const androidDetails = AndroidNotificationDetails(
      'snag_notifications',
      'Snag Notifications',
      channelDescription: 'Notifications for snag due dates and updates',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    await _notifications.show(id, title, body, details);
  }

  List<AppNotification> getNotifications() {
    return _notificationBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> markAsRead(String notificationId) async {
    final notification = _notificationBox.get(notificationId);
    if (notification != null) {
      notification.isRead = true;
      await notification.save();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationBox.delete(notificationId);
  }

  int get unreadCount => _notificationBox.values.where((n) => !n.isRead).length;

  Future<void> createAssignmentNotification(String snagName) async {
    await _createNotification(
      title: '${AppStrings.snag()} is approaching due date',
      message: '$snagName is approaching due date',
      type: NotificationType.dueDateApproaching,
    );
  }

  Future<void> checkDueDateReminders(WidgetRef ref) async {
    final projectBox = Hive.box<Project>('projects');
    final snagBox = Hive.box<Snag>('snags');
    final projects = projectBox.values.toList();
    final now = DateTime.now();
    
    // Group snags by project that are within reminder threshold
    final Map<String, List<Snag>> projectSnags = {};
    
    for (final project in projects) {
      final approachingSnags = <Snag>[];
      
      for (final snag in snagBox.values.where((s) => s.projectId == project.id!).toList()) {
        if (snag.dueDate != null) {
          final daysUntilDue = snag.dueDate!.difference(now).inDays;
          
          if (daysUntilDue <= AppDueDateReminder.dueDateReminderDays && daysUntilDue >= 0) {
            approachingSnags.add(snag);
          }
        }
      }
      
      if (approachingSnags.isNotEmpty) {
        projectSnags[project.name] = approachingSnags;
      }
    }
    
    // Create one notification per project
    for (final entry in projectSnags.entries) {
      final projectName = entry.key;
      final snags = entry.value;
      
      if (snags.length == 1) {
        final snag = snags.first;
        final daysUntilDue = snag.dueDate!.difference(now).inDays;
        await _createNotification(
          title: '${AppStrings.snag()} Due Soon',
          message: '${snag.name} in $projectName is due in ${daysUntilDue == 0 ? 'today' : '$daysUntilDue day${daysUntilDue == 1 ? '' : 's'}'}',
          type: NotificationType.dueDateApproaching,
          snagId: snag.uuid,
        );
      } else {
        await _createNotification(
          title: 'Multiple ${AppStrings.snags()} Due Soon',
          message: '${snags.length} ${AppStrings.snags().toLowerCase()} in $projectName are approaching their due dates',
          type: NotificationType.dueDateApproaching,
        );
      }
    }
  }

  // Future<void> createStatusChangeNotification(String snagName, String newStatus) async {
  //   await _createNotification(
  //     title: 'Status Updated',
  //     message: '$snagName status changed to $newStatus',
  //     type: NotificationType.statusChange,
  //   );
  // }
}
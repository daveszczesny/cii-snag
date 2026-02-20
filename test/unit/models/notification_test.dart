import 'package:flutter_test/flutter_test.dart';
import 'package:cii/models/notification.dart';

void main() {
  group("Notification Model Tests", () {

    test("should have notification types", () {
      expect(NotificationType.values, hasLength(2));
      expect(NotificationType.values, contains(NotificationType.dueDateApproaching));
      expect(NotificationType.values, contains(NotificationType.overdue));
    });

    test("should create notification with required fields", () {
      final createdAt = DateTime.now();
      final notification = AppNotification(
        id: "notif-123",
        title: "Test Notification",
        message: "Test message",
        type: NotificationType.dueDateApproaching,
        createdAt: createdAt,
      );

      expect(notification.id, "notif-123");
      expect(notification.title, "Test Notification");
      expect(notification.message, "Test message");
      expect(notification.type, NotificationType.dueDateApproaching);
      expect(notification.createdAt, createdAt);
      expect(notification.snagId, isNull);
      expect(notification.projectId, isNull);
      expect(notification.isRead, false);
    });

    test("should create notification with all fields", () {
      final createdAt = DateTime.now();
      final notification = AppNotification(
        id: "notif-456",
        title: "Overdue Notification",
        message: "Task is overdue",
        type: NotificationType.overdue,
        createdAt: createdAt,
        snagId: "snag-123",
        projectId: "project-456",
        isRead: true,
      );

      expect(notification.id, "notif-456");
      expect(notification.title, "Overdue Notification");
      expect(notification.message, "Task is overdue");
      expect(notification.type, NotificationType.overdue);
      expect(notification.createdAt, createdAt);
      expect(notification.snagId, "snag-123");
      expect(notification.projectId, "project-456");
      expect(notification.isRead, true);
    });

    test("should allow updating isRead status", () {
      final notification = AppNotification(
        id: "notif-789",
        title: "Test",
        message: "Test message",
        type: NotificationType.dueDateApproaching,
        createdAt: DateTime.now(),
      );

      expect(notification.isRead, false);
      
      notification.isRead = true;
      
      expect(notification.isRead, true);
    });

  });
}
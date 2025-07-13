import 'dart:async';
import 'package:cii/controllers/notification_controller.dart';

class BackgroundNotificationService {
  static final BackgroundNotificationService _instance = BackgroundNotificationService._internal();
  factory BackgroundNotificationService() => _instance;
  BackgroundNotificationService._internal();

  Timer? _timer;
  final NotificationController _notificationController = NotificationController();

  void startPeriodicChecks() {
    // Check every 30 minutes
    _timer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _notificationController.checkAndCreateNotifications();
    });
  }

  void stopPeriodicChecks() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stopPeriodicChecks();
  }
}
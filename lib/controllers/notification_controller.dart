import 'package:cii/services/notification_service.dart';
import 'package:cii/models/snag.dart';
import 'package:hive/hive.dart';

class NotificationController {
  final NotificationService _notificationService = NotificationService();
  
  Future<void> checkAndCreateNotifications() async {
    final snagBox = Hive.box<Snag>('snags');
    final snags = snagBox.values.toList();
    
    await _notificationService.checkSnagNotifications(snags);
  }
  
  Future<void> schedulePeriodicChecks() async {
    // This would typically be called from a background service
    // For now, we'll check when the app starts or when snags are modified
    await checkAndCreateNotifications();
  }
}
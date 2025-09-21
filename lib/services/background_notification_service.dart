
import 'package:cii/models/notification.dart';
import 'package:cii/models/project.dart';
import 'package:cii/services/notification_service.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(ProjectAdapter());
      Hive.registerAdapter(AppNotificationAdapter());

      await AppDueDateReminder.loadDueDateReminderPrefs();

      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.checkDueDateReminders();

      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

class BackgroundNotificationService {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);

    await Workmanager().registerPeriodicTask(
      'due-date-check',
      'checkDueDateReminders',
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(minutes: 1),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      )
    );
  }
}
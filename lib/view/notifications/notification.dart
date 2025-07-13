import 'package:flutter/material.dart';
import 'package:cii/services/notification_service.dart';
import 'package:cii/models/notification.dart';
import 'package:cii/utils/colors/app_colors.dart';
import 'package:intl/intl.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = _notificationService.getNotifications();
    });
  }

  void _createTestNotifications() async {
    await _notificationService.createAssignmentNotification('Test Snag 1');
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createTestNotifications,
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications', style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: notification.isRead ? Colors.white : AppColors.cardColor,
      child: ListTile(
        leading: _getNotificationIcon(notification.type),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy HH:mm').format(notification.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!notification.isRead)
              const PopupMenuItem(
                value: 'read',
                child: Text('Mark as read'),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) async {
            if (value == 'read') {
              await _notificationService.markAsRead(notification.id);
              _loadNotifications();
            } else if (value == 'delete') {
              await _notificationService.deleteNotification(notification.id);
              _loadNotifications();
            }
          },
        ),
        onTap: () async {
          if (!notification.isRead) {
            await _notificationService.markAsRead(notification.id);
            _loadNotifications();
          }
        },
      ),
    );
  }

  Widget _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.dueDateApproaching:
        return const Icon(Icons.schedule, color: AppColors.ctaOrange);
      case NotificationType.overdue:
        return const Icon(Icons.warning, color: AppColors.red);
    }
  }
}
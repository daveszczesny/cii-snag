# Notification System

This document describes the notification system implemented in the CII Snag application.

## Features

### Notification Types
1. **Due Date Approaching** - Alerts when snags are due within 3 days
2. **Overdue** - Alerts when snags are past their due date
3. **No Update** - Reminds when snags haven't been updated in 7+ days
4. **Status Change** - Notifies when snag status changes
5. **New Assignment** - Notifies when snags are assigned to someone

### Push Notifications
- Local push notifications are sent for important alerts
- Summary notifications for multiple snags (e.g., "3 snags are approaching their due dates")
- Spam prevention: Similar notifications are limited to once per 24 hours

### In-App Notifications
- Notifications screen displays all notifications with timestamps
- Unread notification badge on navigation bar
- Mark as read/delete functionality
- Themed notification cards matching app design

### Background Processing
- Periodic checks every 30 minutes for new notifications
- Automatic notification generation when snags are modified
- Notifications persist across app sessions

## Implementation

### Key Components
- `NotificationService` - Core notification management
- `NotificationController` - Business logic for notification checks
- `BackgroundNotificationService` - Periodic background checks
- `AppNotification` model - Notification data structure

### Dependencies Added
- `flutter_local_notifications: ^17.2.2` - Push notifications
- `timezone: ^0.9.4` - Timezone handling

### Usage
The system automatically monitors snags and creates notifications based on:
- Due dates and overdue status
- Time since last modification
- Status changes and assignments

No manual intervention required - notifications are generated automatically when conditions are met.
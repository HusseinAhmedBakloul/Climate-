import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> scheduleWeatherNotifications() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'daily_weather',
      title: 'Morning weather update 🌤️',
      body: "Check today's local weather 🌞",
      notificationLayout: NotificationLayout.Default,
    ),
    schedule: NotificationCalendar(
      hour: 7,
      minute: 0,
      second: 0,
      repeats: true,
    ),
  );

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 2,
      channelKey: 'daily_weather',
      title: 'Evening weather update 🌙',
      body: 'Check the local weather tonight 🌜',
      notificationLayout: NotificationLayout.Default,
    ),
    schedule: NotificationCalendar(
      hour: 19,
      minute: 0,
      second: 0,
      repeats: true,
    ),
  );
}

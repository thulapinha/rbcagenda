import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }

  Future<void> scheduleNotification(
      String title, String body, int hour, int minute) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<List<Map<String, dynamic>>> verificarVencimentoDespesas() async {
    User? user = FirebaseAuth.instance.currentUser;
    List<Map<String, dynamic>> despesas = [];

    if (user != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference despesasCollection =
          firestore.collection('users').doc(user.uid).collection('despesas');

      DateTime now = DateTime.now();
      DateTime limite = now.add(const Duration(days: 5));

      QuerySnapshot querySnapshot = await despesasCollection
          .where('vencimento', isGreaterThanOrEqualTo: now)
          .where('vencimento', isLessThanOrEqualTo: limite)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          DateTime vencimento = doc['vencimento'].toDate();
          int diasRestantes = vencimento.difference(now).inDays;

          if (diasRestantes <= 5 && diasRestantes >= 0) {
            despesas.add({
              'nome': doc['nome'],
              'valor': doc['valor'],
              'vencimento': vencimento,
              'diasRestantes': diasRestantes,
            });

            // Exibe a notificação
            showNotification(
              'Vencimento Próximo',
              'A despesa ${doc['nome']} vence em $diasRestantes dias',
            );
          }
        }
      }
    }
    return despesas;
  }
}

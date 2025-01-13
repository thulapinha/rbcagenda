import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        showNotification(notification.title!, notification.body!);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token");
    });
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );
      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          0, notification.title, notification.body, platformChannelSpecifics);
    }
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
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

            // Enviar notificação via FCM
            await _firebaseMessaging.subscribeToTopic(user.uid);
            await FirebaseMessaging.instance.sendMessage(
              to: "/topics/${user.uid}",
              data: {
                "title": "Vencimento Próximo",
                "body": "A despesa ${doc['nome']} vence em $diasRestantes dias"
              },
            );

            // Agendar notificações a cada 2 horas
            for (int i = 1; i <= diasRestantes * 12; i++) {
              await flutterLocalNotificationsPlugin.zonedSchedule(
                i,
                'Vencimento Próximo',
                'A despesa ${doc['nome']} vence em $diasRestantes dias',
                tz.TZDateTime.now(tz.local).add(Duration(hours: 2 * i)),
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'your_channel_id',
                    'your_channel_name',
                    importance: Importance.max,
                    priority: Priority.high,
                    showWhen: true,
                  ),
                ),
                uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
                androidScheduleMode: AndroidScheduleMode.exact,
              );
            }
          }
        }
      }
    }
    return despesas;
  }
}

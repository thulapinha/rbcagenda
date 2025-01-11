import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:AgendaRbc/cadastro/cadastro.dart';
import 'package:AgendaRbc/contato.dart';
import 'package:AgendaRbc/historicios_relatorio/lista_historico_dispesa.dart';
import 'package:AgendaRbc/logo/login.dart';
import 'package:AgendaRbc/home_org/home_page.dart';
import 'package:AgendaRbc/servidor_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final NotificationService notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.grey[850],
        scaffoldBackgroundColor: Colors.grey[850],
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.grey[850],
          secondary: Colors.grey[850],
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: Colors.grey[850],
          scrimColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[850],
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.white,
        ),
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomePage(username: ''),
        '/contato': (context) => const ContatoPage(),
        '/listadispesa': (context) => const ListaDespesasPage(),
      },
    );
  }
}

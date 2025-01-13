import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:AgendaRbc/notifi_avisos_mensage/servidor_notification.dart';

class VencimentoAlertaPage extends StatefulWidget {
  const VencimentoAlertaPage({super.key});

  @override
  _VencimentoAlertaPageState createState() => _VencimentoAlertaPageState();
}

class _VencimentoAlertaPageState extends State<VencimentoAlertaPage> {
  final NotificationService _notificationService = NotificationService();
  final List<Map<String, dynamic>> _despesas = [];

  @override
  void initState() {
    super.initState();
    _notificationService.initialize().then((_) {
      _verificarVencimentoDespesas();
    });
  }

  Future<void> _verificarVencimentoDespesas() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference despesas =
      firestore.collection('users').doc(user.uid).collection('despesas');

      DateTime now = DateTime.now();
      DateTime limite = now.add(const Duration(days: 5));

      QuerySnapshot querySnapshot = await despesas
          .where('vencimento', isGreaterThanOrEqualTo: now)
          .where('vencimento', isLessThanOrEqualTo: limite)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          DateTime vencimento = doc['vencimento'].toDate();
          int diasRestantes = vencimento.difference(now).inDays;

          if (diasRestantes <= 5 && diasRestantes >= 0) {
            _despesas.add({
              'nome': doc['nome'],
              'valor': doc['valor'],
              'vencimento': vencimento,
              'diasRestantes': diasRestantes,
            });

            // Exibe a notificação
            _notificationService.showNotification(
              'Vencimento Próximo',
              'A despesa ${doc['nome']} vence em $diasRestantes dias',
            );
          }
        }
        if (mounted) {
          _mostrarAlertaVencimento();
        }
      } else {
        if (mounted) {
          // Redireciona de volta para HomePage se não houver despesas
          Navigator.pop(context);
        }
      }
    }
  }

  void _mostrarAlertaVencimento() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Vencimento Próximo',
            style: TextStyle(color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _despesas.map((despesa) {
              return ListTile(
                title: Text(
                  despesa['nome'],
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: Text(
                  'Valor: ${despesa['valor']} \nVencimento: ${despesa['vencimento'].day}/${despesa['vencimento'].month}/${despesa['vencimento'].year} \nDias Restantes: ${despesa['diasRestantes']}',
                  style: TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {
      if (mounted) {
        // Redireciona de volta para HomePage após fechar o diálogo
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerta de Vencimento',style: TextStyle(color: Colors.black),),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
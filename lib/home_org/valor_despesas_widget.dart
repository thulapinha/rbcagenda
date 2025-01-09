import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ValorDespesasWidget extends StatefulWidget {
  const ValorDespesasWidget({super.key});

  @override
  _ValorDespesasWidgetState createState() => _ValorDespesasWidgetState();
}

class _ValorDespesasWidgetState extends State<ValorDespesasWidget> {
  bool _exibirValor = true;

  @override
  void initState() {
    super.initState();
    _fetchExibirValor();
  }

  Future<void> _fetchExibirValor() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _exibirValor = result['exibirValor'] ?? true;
      });
    }
  }

  Stream<double> _buscarValorTotalDespesas() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(0.0);

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference despesas =
        firestore.collection('users').doc(user.uid).collection('despesas');

    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return despesas
        .where('vencimento', isGreaterThanOrEqualTo: firstDayOfMonth)
        .where('vencimento', isLessThanOrEqualTo: lastDayOfMonth)
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        try {
          double valor = doc['valor'];
          total += valor;
        } catch (e) {
          print("Erro ao obter o valor da despesa (${doc['valor']}): $e");
        }
      }
      return total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: _buscarValorTotalDespesas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar as despesas.'));
        } else if (snapshot.hasData) {
          double valorTotalDespesas = snapshot.data ?? 0.0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: _exibirValor
                    ? Text(
                        'R\$ ${valorTotalDespesas.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Icon(
                        Icons.visibility_off,
                        color: Colors.white,
                      ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Despesas do Mês',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text('Nenhuma despesa encontrada.'));
        }
      },
    );
  }
}

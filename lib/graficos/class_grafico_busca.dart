// services/despesa_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DespesaService {
  Future<List<Despesa>> buscarDespesas() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference despesas =
      firestore.collection('users').doc(user.uid).collection('despesas');

      DateTime now = DateTime.now();
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
      DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      QuerySnapshot querySnapshot = await despesas
          .where('vencimento', isGreaterThanOrEqualTo: firstDayOfMonth)
          .where('vencimento', isLessThanOrEqualTo: lastDayOfMonth)
          .get();

      return querySnapshot.docs.map((doc) {
        try {
          double valor = doc['valor'];
          return Despesa(nome: doc['nome'], valor: valor);
        } catch (e) {
          print("Erro ao converter o valor da despesa (${doc['valor']}): $e");
          return Despesa(nome: doc['nome'], valor: 0.0);
        }
      }).toList();
    }
    return [];
  }

  Future<List<Despesa>> buscarDespesasPagas() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference historico =
      firestore.collection('users').doc(user.uid).collection('historico');

      QuerySnapshot querySnapshot = await historico.get();

      return querySnapshot.docs.map((doc) {
        try {
          double valor = doc['valor'];
          return Despesa(nome: doc['nome'], valor: valor);
        } catch (e) {
          print("Erro ao converter o valor da despesa paga (${doc['valor']}): $e");
          return Despesa(nome: doc['nome'], valor: 0.0);
        }
      }).toList();
    }
    return [];
  }
}

class Despesa {
  final String nome;
  final double valor;

  Despesa({required this.nome, required this.valor});
}

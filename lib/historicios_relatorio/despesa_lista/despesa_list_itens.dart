import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DespesaListItem extends StatelessWidget {
  final DocumentSnapshot despesa;
  final bool editarDespesa;
  final Function onConfirmarPagamento;
  final Function onEditarDespesa;

  const DespesaListItem({
    super.key,
    required this.despesa,
    required this.editarDespesa,
    required this.onConfirmarPagamento,
    required this.onEditarDespesa,
  });

  Future<Map<String, dynamic>> _getDespesaData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot despesaSnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('despesas')
          .doc(despesa.id)
          .get();
      return despesaSnapshot.data() as Map<String, dynamic>;
    }
    return despesa.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getDespesaData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return const Text('Erro ao carregar dados',
              style: TextStyle(color: Colors.red));
        }

        Map<String, dynamic> despesaData = snapshot.data!;

        print('Despesa Data: $despesaData'); // Print para depuração

        return ListTile(
          title: Text(despesaData['nome'],
              style: const TextStyle(color: Colors.white)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Valor: ${despesaData['valor']} \nVencimento: ${despesaData['vencimento'].toDate().day}/${despesaData['vencimento'].toDate().month}/${despesaData['vencimento'].toDate().year}',
                style: const TextStyle(color: Colors.white),
              ),
              if (despesaData.containsKey('parcelas'))
                Text(
                  'Parcelas: ${despesaData['parcelas']}',
                  style: const TextStyle(color: Colors.white),
                ),
            ],
          ),
          isThreeLine: true,
          onTap: editarDespesa
              ? () => onEditarDespesa(despesa)
              : () => onConfirmarPagamento(despesa),
        );
      },
    );
  }
}

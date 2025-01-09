import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoricoPage extends StatelessWidget {
  const HistoricoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Histórico de Pagamentos',
              style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
            child: Text('Usuário não autenticado',
                style: TextStyle(color: Colors.white))),
        backgroundColor: Colors.grey[850],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Pagamentos',
            style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, configSnapshot) {
          if (!configSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final configData =
              configSnapshot.data!.data() as Map<String, dynamic>?;
          final mostrarHistorico = configData?['mostrarHistorico'] ?? false;
          final num mesesHistorico = configData?['mesesHistorico'] ?? 3;
          final excluirAtivo = configData?['excluirAtivo'] ?? false;

          if (!mostrarHistorico) {
            return const Center(
                child: Text('Histórico não está habilitado',
                    style: TextStyle(color: Colors.white)));
          }

          final now = DateTime.now();
          final cutoffDate =
              DateTime(now.year, now.month - mesesHistorico.toInt(), now.day);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('historico')
                .where('vencimento', isGreaterThan: cutoffDate)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final despesasPagas = snapshot.data!.docs;

              double totalPago = despesasPagas.fold(0, (sum, despesa) {
                final data = despesa.data() as Map<String, dynamic>?;
                return sum + (data != null ? data['valor'] : 0);
              });

              print('Despesas Pagas: $despesasPagas'); // Print para depuração
              print('Total Pago: $totalPago'); // Print para depuração

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Total Pago: R\$ ${totalPago.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: despesasPagas.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot despesa = despesasPagas[index];
                        final data = despesa.data() as Map<String, dynamic>?;
                        return Column(
                          children: [
                            ListTile(
                              title: Text(
                                data?['nome'] ?? 'Nome não disponível',
                                style: const TextStyle(color: Colors.green),
                              ),
                              subtitle: Text(
                                'Valor: R\$ ${data?['valor'] ?? 0} \nPago em: ${data?['vencimento'] != null ? '${data!['vencimento'].toDate().day.toString().padLeft(2, '0')}/${data['vencimento'].toDate().month.toString().padLeft(2, '0')}/${data['vencimento'].toDate().year}' : 'Data não disponível'}',
                                style: const TextStyle(color: Colors.green),
                              ),
                              isThreeLine: true,
                              onTap: excluirAtivo
                                  ? () => _confirmarExclusao(
                                      context, user.uid, despesa.id)
                                  : null,
                            ),
                            const Divider(
                                color: Colors
                                    .green), // Linha verde para separar as despesas
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      backgroundColor: Colors.grey[850],
    );
  }

  void _confirmarExclusao(
      BuildContext context, String userId, String despesaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão',
              style: TextStyle(color: Colors.black)),
          content: const Text('Deseja realmente excluir esta despesa?',
              style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _excluirDespesa(userId, despesaId);
                Navigator.of(context).pop(); // Fechar o diálogo
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _excluirDespesa(String userId, String despesaId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('historico')
        .doc(despesaId)
        .delete();
    print('Despesa excluída: $despesaId'); // Print para depuração
  }
}

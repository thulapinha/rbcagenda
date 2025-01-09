import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfHistorico extends StatefulWidget {
  const ConfHistorico({super.key});

  @override
  _ConfHistoricoState createState() => _ConfHistoricoState();
}

class _ConfHistoricoState extends State<ConfHistorico> {
  bool mostrarHistorico = false;
  bool mostrarDividas = false;
  int mesesHistorico = 3;
  int numDividas = 10;
  bool excluirAtivo = false;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  Future<void> _carregarConfiguracoes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        setState(() {
          mostrarHistorico = snapshot['mostrarHistorico'] ?? false;
          mostrarDividas = snapshot['mostrarDividas'] ?? false;
          mesesHistorico = snapshot['mesesHistorico'] ?? 3;
          numDividas = snapshot['numDividas'] ?? 10;
          excluirAtivo = snapshot['excluirAtivo'] ?? false;
        });
      }
    }
  }

  Future<void> _salvarConfiguracoes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'mostrarHistorico': mostrarHistorico,
        'mostrarDividas': mostrarDividas,
        'mesesHistorico': mesesHistorico,
        'numDividas': numDividas,
        'excluirAtivo': excluirAtivo,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _toggleExibirValor() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final exibirValor = result['exibirValor'] ?? true;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'exibirValor': !exibirValor,
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração do Histórico',
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text(
                'Mostrar Histórico',
                style: TextStyle(color: Colors.white),
              ),
              value: mostrarHistorico,
              onChanged: (bool value) {
                setState(() {
                  mostrarHistorico = value;
                  _salvarConfiguracoes();
                });
              },
              activeColor: Colors.green, // Cor quando o switch está ativo
              inactiveThumbColor:
                  Colors.red, // Cor do polegar quando o switch está inativo
              inactiveTrackColor: Colors
                  .redAccent, // Cor da trilha quando o switch está inativo
            ),
            ListTile(
              title: const Text(
                'Definir o tempo que o histórico fica disponível (meses)',
                style: TextStyle(color: Colors.white),
              ),
              trailing: DropdownButton<int>(
                value: mesesHistorico,
                onChanged: (int? newValue) {
                  setState(() {
                    mesesHistorico = newValue!;
                    _salvarConfiguracoes();
                  });
                },
                items:
                    <int>[1, 3, 6, 12].map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      value.toString(),
                      style: const TextStyle(color: Colors.green),
                    ),
                  );
                }).toList(),
              ),
            ),
            SwitchListTile(
              title: const Text(
                'Mostrar Dívidas',
                style: TextStyle(color: Colors.white),
              ),
              value: mostrarDividas,
              onChanged: (bool value) {
                setState(() {
                  mostrarDividas = value;
                  _salvarConfiguracoes();
                });
              },
              activeColor: Colors.green, // Cor quando o switch está ativo
              inactiveThumbColor:
                  Colors.red, // Cor do polegar quando o switch está inativo
              inactiveTrackColor: Colors
                  .redAccent, // Cor da trilha quando o switch está inativo
            ),
            ListTile(
              title: const Text(
                'Número de Dívidas a Exibir',
                style: TextStyle(color: Colors.white),
              ),
              trailing: DropdownButton<int>(
                value: numDividas,
                onChanged: (int? newValue) {
                  setState(() {
                    numDividas = newValue!;
                    _salvarConfiguracoes();
                  });
                },
                items: <int>[5, 10, 15, 20]
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      value.toString(),
                      style: const TextStyle(color: Colors.green),
                    ),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  excluirAtivo = !excluirAtivo;
                  _salvarConfiguracoes();
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  excluirAtivo ? Colors.green : Colors.grey,
                ),
              ),
              child: const Text('Ativar Exclusão Manual'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleExibirValor,
              child: const Text('Visualizar Valor Total das Despesas'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[850],
    );
  }
}

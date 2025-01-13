import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:screenshot/screenshot.dart';

class RelatorioDespesasPage extends StatefulWidget {
  const RelatorioDespesasPage({super.key});

  @override
  _RelatorioDespesasPageState createState() => _RelatorioDespesasPageState();
}

class _RelatorioDespesasPageState extends State<RelatorioDespesasPage> {
  List<DocumentSnapshot> _historico = [];
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _buscarDespesasDoMes();
  }

  Future<void> _buscarDespesasDoMes() async {
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

      setState(() {
        _historico = querySnapshot.docs;
      });
    }
  }

  Future<void> _capturarImagem() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = File(
      '${directory.path}/relatorio_despesas.png',
    );

    screenshotController
        .captureAndSave(
      directory.path,
      fileName: 'relatorio_despesas.png',
    )
        .then((String? filePath) {
      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imagem salva em $filePath')),
        );
      }
    }).catchError((onError) {
      print(onError);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao salvar a imagem')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Relatório de Despesas',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Screenshot(
        controller: screenshotController,
        child: ListView.builder(
          itemCount: _historico.length,
          itemBuilder: (context, index) {
            DocumentSnapshot despesa = _historico[index];
            return ListTile(
              title: Text(
                despesa['nome'],
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Valor: ${despesa['valor']} \nVencimento: ${despesa['vencimento'].toDate().day}/${despesa['vencimento'].toDate().month}/${despesa['vencimento'].toDate().year}',
                style: TextStyle(color: Colors.white),
              ),
              isThreeLine: true,
            );
          },
        ),
      ),
      floatingActionButton: Center(
        child: ElevatedButton(
          onPressed: _capturarImagem,
          child: const Text("Salvar Imagem"),
        ),
      ),
    );
  }
}

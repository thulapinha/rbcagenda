import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraficoDespesasPage extends StatefulWidget {
  const GraficoDespesasPage({super.key});

  @override
  _GraficoDespesasPageState createState() => _GraficoDespesasPageState();
}

class _GraficoDespesasPageState extends State<GraficoDespesasPage> {
  List<CircularSeries<Despesa, String>> _circularSeriesList = [];
  List<CartesianSeries<Despesa, String>> _chartSeriesList = [];
  final bool _isPieChart = true;

  @override
  void initState() {
    super.initState();
    _buscarDespesas();
  }

  Future<void> _buscarDespesas() async {
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

      List<Despesa> despesasList = querySnapshot.docs.map((doc) {
        try {
          double valor = doc[
              'valor']; // Assumindo que o valor já está salvo como double no Firebase

          return Despesa(
            nome: doc['nome'],
            valor: valor, // Já é double
          );
        } catch (e) {
          print("Erro ao converter o valor da despesa (${doc['valor']}): $e");
          return Despesa(nome: doc['nome'], valor: 0.0);
        }
      }).toList();

      _gerarGraficos(despesasList);
    }
  }

  void _gerarGraficos(List<Despesa> despesasList) {
    setState(() {
      if (_isPieChart) {
        _circularSeriesList = [
          PieSeries<Despesa, String>(
            dataSource: despesasList,
            xValueMapper: (Despesa despesa, _) => despesa.nome,
            yValueMapper: (Despesa despesa, _) => despesa.valor,
            dataLabelMapper: (Despesa despesa, _) =>
                '${despesa.nome}: ${despesa.valor.toStringAsFixed(2)}',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold, // Define o texto em negrito
              ),
            ),
          ),
        ];
        _chartSeriesList = [];
      } else {
        _chartSeriesList = [
          ColumnSeries<Despesa, String>(
            dataSource: despesasList,
            xValueMapper: (Despesa despesa, _) => despesa.nome,
            yValueMapper: (Despesa despesa, _) => despesa.valor,
            dataLabelMapper: (Despesa despesa, _) =>
                '${despesa.nome}: ${despesa.valor.toStringAsFixed(2)}',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold, // Define o texto em negrito
              ),
            ),
          ),
        ];
        _circularSeriesList = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gráfico de Despesas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold, // Define o texto em negrito
          ),
        ),
        backgroundColor: Colors.grey[850], // Fundo cinza escuro
      ),
      body: _isPieChart
          ? (_circularSeriesList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SfCircularChart(
                    legend: Legend(
                      isVisible: true,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold, // Define o texto em negrito
                      ),
                    ), // Texto branco na legenda
                    series: _circularSeriesList,
                  ),
                ))
          : (_chartSeriesList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SfCartesianChart(
                    legend: Legend(
                      isVisible: true,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold, // Define o texto em negrito
                      ),
                    ), // Texto branco na legenda
                    series: _chartSeriesList,
                  ),
                )),
      backgroundColor: Colors.grey[850], // Fundo cinza escuro
    );
  }
}

class Despesa {
  final String nome;
  final double valor;

  Despesa({required this.nome, required this.valor});
}

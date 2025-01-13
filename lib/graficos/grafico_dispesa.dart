// pages/grafico_despesas_page.dart
import 'package:AgendaRbc/graficos/class_grafico_busca.dart';
import 'package:AgendaRbc/graficos/widgat_grafic_despes.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraficoDespesasPage extends StatefulWidget {
  const GraficoDespesasPage({super.key});

  @override
  _GraficoDespesasPageState createState() => _GraficoDespesasPageState();
}

class _GraficoDespesasPageState extends State<GraficoDespesasPage> {
  final DespesaService _despesaService = DespesaService();
  List<PieSeries<Despesa, String>> _circularSeriesList = [];
  List<PieSeries<Despesa, String>> _circularSeriesPagasList = [];
  double _totalDespesas = 0.0;
  double _totalDespesasPagas = 0.0;

  @override
  void initState() {
    super.initState();
    _carregarDespesas();
  }

  Future<void> _carregarDespesas() async {
    List<Despesa> despesas = await _despesaService.buscarDespesas();
    List<Despesa> despesasPagas = await _despesaService.buscarDespesasPagas();

    setState(() {
      _totalDespesas = despesas.fold(0, (sum, item) => sum + item.valor);
      _totalDespesasPagas = despesasPagas.fold(0, (sum, item) => sum + item.valor);

      _circularSeriesList = [
        PieSeries<Despesa, String>(
          dataSource: despesas,
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

      _circularSeriesPagasList = [
        PieSeries<Despesa, String>(
          dataSource: despesasPagas,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            GraficoDespesasWidget(
              titulo: 'Despesas a Vencer',
              total: _totalDespesas,
              seriesList: _circularSeriesList,
              valorCor: Colors.red, // Define a cor vermelha para valor do débito
            ),
            const Divider(
              color: Colors.white, // Cor da linha separadora
              thickness: 2, // Espessura da linha separadora
            ),
            GraficoDespesasWidget(
              titulo: 'Despesas Pagas',
              total: _totalDespesasPagas,
              seriesList: _circularSeriesPagasList,
              valorCor: Colors.green, // Define a cor verde para valor pago
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[850], // Fundo cinza escuro
    );
  }
}

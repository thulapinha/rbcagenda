// widgets/grafico_despesas_widget.dart
import 'package:AgendaRbc/graficos/class_grafico_busca.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraficoDespesasWidget extends StatelessWidget {
  final String titulo;
  final double total;
  final List<PieSeries<Despesa, String>> seriesList;
  final Color valorCor;  // Nova propriedade para cor do valor

  const GraficoDespesasWidget({
    Key? key,
    required this.titulo,
    required this.total,
    required this.seriesList,
    required this.valorCor,  // Inclui cor no construtor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold, // Define o texto em negrito
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total: R\$ ${total.toStringAsFixed(2)}',
            style: TextStyle(
              color: valorCor, // Usa a cor fornecida
              fontSize: 16,
              fontWeight: FontWeight.bold, // Define o texto em negrito
            ),
          ),
          seriesList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(8.0),
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold, // Define o texto em negrito
                ),
              ), // Texto branco na legenda
              series: seriesList,
            ),
          ),
        ],
      ),
    );
  }
}

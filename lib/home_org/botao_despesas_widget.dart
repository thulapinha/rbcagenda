import 'package:flutter/material.dart';
import 'package:AgendaRbc/cadastro/cadastro_dispesa.dart';
import 'package:AgendaRbc/historicios_relatorio/lista_historico_dispesa.dart';

class BotaoDespesasWidget extends StatelessWidget {
  const BotaoDespesasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CadastroDespesaPage()),
            );
          },
          icon: const Icon(Icons.money_off),
          label: const Text('Despesa'),
        ),
        const SizedBox(width: 20),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ListaDespesasPage()),
            );
          },
          icon: const Icon(Icons.list),
          label: const Text('Lista Despesas'),
        ),
      ],
    );
  }
}

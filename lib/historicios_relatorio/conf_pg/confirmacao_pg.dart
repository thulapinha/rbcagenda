import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfirmarPagamentoDialog extends StatelessWidget {
  final DocumentSnapshot despesa;
  final Function onConfirm;

  const ConfirmarPagamentoDialog({
    super.key,
    required this.despesa,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[300],
      title: const Text('Confirmar Pagamento',
          style: TextStyle(color: Colors.black)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Você pagou a despesa "${despesa['nome']}"?',
              style: const TextStyle(color: Colors.black)),
          const SizedBox(height: 16),
          Text('Valor: ${despesa['valor']}',
              style: const TextStyle(color: Colors.black)),
          Text(
              'Vencimento: ${despesa['vencimento'].toDate().day}/${despesa['vencimento'].toDate().month}/${despesa['vencimento'].toDate().year}',
              style: const TextStyle(color: Colors.black)),
          if (despesa.data() != null &&
              (despesa.data() as Map<String, dynamic>)
                  .containsKey('parcelas_restantes'))
            Text('Parcelas Restantes: ${despesa['parcelas_restantes']}',
                style: const TextStyle(color: Colors.black)),
        ],
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            side: BorderSide(color: Colors.grey[700]!, width: 1),
          ),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Não'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            side: BorderSide(color: Colors.grey[700]!, width: 1),
          ),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(true);
          },
          child: const Text('Sim'),
        ),
      ],
    );
  }
}

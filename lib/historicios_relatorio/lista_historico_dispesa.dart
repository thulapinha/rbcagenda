import 'package:AgendaRbc/historicios_relatorio/conf_pg/confirmacao_pg.dart';
import 'package:AgendaRbc/historicios_relatorio/despesa_lista/despesa_list_itens.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'historico_pg_despesa.dart';

class ListaDespesasPage extends StatefulWidget {
  final bool editarDespesa;

  const ListaDespesasPage({super.key, this.editarDespesa = false});

  @override
  _ListaDespesasPageState createState() => _ListaDespesasPageState();
}

class _ListaDespesasPageState extends State<ListaDespesasPage> {
  List<DocumentSnapshot> _despesas = [];

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
        _despesas = querySnapshot.docs;
      });

      print('Despesas: $_despesas'); // Print para depuração
    }
  }

  Future<void> _confirmarPagamento(DocumentSnapshot despesa) async {
    print('Confirmando pagamento para despesa: ${despesa.data()}'); // Print para depuração
    bool confirmacao = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmarPagamentoDialog(
          despesa: despesa,
          onConfirm: () async {
            print('Despesa antes de deletar: ${despesa.data()}'); // Print para depuração
            await despesa.reference.delete();
            print('Despesa deletada'); // Print para depuração
            await _salvarHistorico(despesa);
            _buscarDespesasDoMes(); // Recarregar as despesas
          },
        );
      },
    );

    if (confirmacao == true) {
      print('Pagamento confirmado para despesa: ${despesa.data()}'); // Print para depuração
      _buscarDespesasDoMes(); // Recarregar as despesas
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HistoricoPage()),
      );
    }
  }

  Future<void> _salvarHistorico(DocumentSnapshot despesa) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference historico =
      firestore.collection('users').doc(user.uid).collection('historico');
      await historico.add(despesa.data());
      print('Despesa salva no histórico: ${despesa.data()}'); // Print para depuração
    } else {
      print('Erro: Usuário não autenticado');
    }
  }

  void _editarDespesa(DocumentSnapshot despesa) {
    if (widget.editarDespesa) {
      // Função de edição de despesa
      _showEditDialog(despesa);
    } else {
      print("Acesso negado. Você não clicou no ícone de editar despesa.");
    }
  }

  void _showEditDialog(DocumentSnapshot despesa) {
    // Aqui vai o código de edição de despesa que você já tem
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nomeController =
        TextEditingController(text: despesa['nome']);
        TextEditingController valorController =
        TextEditingController(text: despesa['valor'].toString());
        DateTime vencimento = despesa['vencimento'].toDate();
        TextEditingController vencimentoController =
        TextEditingController(text: DateFormat('dd/MM/yyyy').format(vencimento));
        TextEditingController parcelasController = TextEditingController();

        final despesaData = despesa.data() as Map<String, dynamic>;
        if (despesaData.containsKey('parcelas')) {
          parcelasController.text = despesaData['parcelas'].toString();
        }

        return AlertDialog(
          title: const Text(
            'Editar Despesa',
            style: TextStyle(color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              TextField(
                controller: valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  valorController.text = value.replaceAll(',', '.');
                  valorController.selection = TextSelection.fromPosition(
                      TextPosition(offset: valorController.text.length));
                },
              ),
              TextField(
                controller: vencimentoController,
                decoration: const InputDecoration(
                  labelText: 'Vencimento',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                keyboardType: TextInputType.datetime,
                style: const TextStyle(color: Colors.black),
              ),
              if (despesaData.containsKey('parcelas'))
                TextField(
                  controller: parcelasController,
                  decoration: const InputDecoration(
                    labelText: 'Parcelas',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Converte a string no formato dd/MM/yyyy para um objeto DateTime
                DateTime parsedVencimento =
                DateFormat('dd/MM/yyyy').parse(vencimentoController.text);

                // Lógica para atualizar a despesa no Firestore
                await despesa.reference.update({
                  'nome': nomeController.text,
                  'valor': double.parse(valorController.text),
                  'vencimento': Timestamp.fromDate(parsedVencimento),
                  if (parcelasController.text.isNotEmpty)
                    'parcelas': int.parse(parcelasController.text),
                });
                print('Despesa atualizada: ${despesa.data()}'); // Print para depuração
                Navigator.of(context).pop();
                _buscarDespesasDoMes(); // Recarregar as despesas
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Despesas do Mês', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        itemCount: _despesas.length,
        itemBuilder: (context, index) {
          DocumentSnapshot despesa = _despesas[index];
          return Column(
            children: [
              DespesaListItem(
                despesa: despesa,
                editarDespesa: widget.editarDespesa,
                onConfirmarPagamento: _confirmarPagamento,
                onEditarDespesa: _editarDespesa,
              ),
              const Divider(color: Colors.white), // Linha branca para separar as despesas
            ],
          );
        },
      ),
      backgroundColor: Colors.grey[850],
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoricoPage()),
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.history),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CadastroDespesaPage extends StatefulWidget {
  const CadastroDespesaPage({super.key});

  @override
  _CadastroDespesaPageState createState() => _CadastroDespesaPageState();
}

class _CadastroDespesaPageState extends State<CadastroDespesaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _parcelasController = TextEditingController();
  bool _isParcelada = false;
  bool _isLoading = false;  // Variável para indicar estado de carregamento
  DateTime _vencimento = DateTime.now();

  Future<void> _salvarDespesa() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        CollectionReference despesas =
        firestore.collection('users').doc(user.uid).collection('despesas');

        double valor = double.parse(_valorController.text.replaceAll(',', '.'));
        int parcelas = _isParcelada ? int.parse(_parcelasController.text) : 1;

        for (int i = 0; i < parcelas; i++) {
          await despesas.add({
            'nome': _nomeController.text,
            'valor': valor,  // Mantém o valor total para cada parcela
            'vencimento': DateTime(_vencimento.year, _vencimento.month + i, _vencimento.day),
            'descricao': _descricaoController.text,
            'parcelas': parcelas,
            'parcelas_restantes': parcelas - i,
            'criado_em': Timestamp.now(),
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Despesa cadastrada com sucesso')),
        );

        // Limpa os campos após salvar
        _nomeController.clear();
        _valorController.clear();
        _descricaoController.clear();
        _parcelasController.clear();
        setState(() {
          _isParcelada = false;
          _vencimento = DateTime.now();
          _isLoading = false;
        });

        // Redireciona para HomePage
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, faça login para cadastrar a despesa')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cadastro de Despesa', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[850],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Despesa',
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome da despesa';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _valorController,
                      decoration: const InputDecoration(
                        labelText: 'Valor da Despesa (R\$)',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                      ],
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o valor da despesa';
                        }
                        return null;
                      },
                    ),
                    SwitchListTile(
                      title: const Text('A despesa será parcelada?', style: TextStyle(color: Colors.white)),
                      value: _isParcelada,
                      onChanged: (bool value) {
                        setState(() {
                          _isParcelada = value;
                        });
                      },
                    ),
                    if (_isParcelada)
                      TextFormField(
                        controller: _parcelasController,
                        decoration: const InputDecoration(
                          labelText: 'Número de Parcelas',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty || int.tryParse(value) == null) {
                            return 'Por favor, insira um número válido de parcelas';
                          }
                          return null;
                        },
                      ),
                    ListTile(
                      title: const Text('Data de Vencimento', style: TextStyle(color: Colors.white)),
                      subtitle: Text(
                          '${_vencimento.day}/${_vencimento.month}/${_vencimento.year}',
                          style: const TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.calendar_today, color: Colors.white),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _vencimento,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null && pickedDate != _vencimento) {
                          setState(() {
                            _vencimento = pickedDate;
                          });
                        }
                      },
                    ),
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição (opcional)',
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _salvarDespesa,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Cadastrar Despesa'),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.grey[850],
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    _descricaoController.dispose();
    _parcelasController.dispose();
    super.dispose();
  }
}

import 'package:AgendaRbc/congigura_historico.dart';
import 'package:flutter/material.dart';
import 'package:AgendaRbc/grafico_dispesa.dart';
import 'package:AgendaRbc/home_org/botao_despesas_widget.dart';
import 'package:AgendaRbc/home_org/menu_drawer.dart';
import 'package:AgendaRbc/home_org/valor_despesas_widget.dart';
import 'package:AgendaRbc/servidor_notification.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NotificationService _notificationService = NotificationService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarDespesas();
    });
  }

  Future<void> _verificarDespesas() async {
    List<Map<String, dynamic>> despesas = await _notificationService.verificarVencimentoDespesas();
    if (despesas.isNotEmpty) {
      _mostrarAlertaVencimento(despesas);
    }
  }

  void _mostrarAlertaVencimento(List<Map<String, dynamic>> despesas) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vencimento Próximo', style: TextStyle(color: Colors.black)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: despesas.map((despesa) {
                  return ListTile(
                    title: Text(
                      despesa['nome'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Valor: ${despesa['valor']}\n',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'Vencimento: ${despesa['vencimento'].day}/${despesa['vencimento'].month}/${despesa['vencimento'].year}\n',
                            style: const TextStyle(color: Colors.red),
                          ),
                          TextSpan(
                            text: despesa['diasRestantes'] == 0
                                ? 'Falta 1 dia'
                                : despesa['diasRestantes'] < 0
                                ? 'Vencido'
                                : 'Dias Restantes: ${despesa['diasRestantes']}',
                            style: TextStyle(
                              color: despesa['diasRestantes'] <= 0 ? Colors.red : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
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
        title: Text(widget.username),
      ),
      drawer: MenuDrawer(
        logoutCallback: () {
          Navigator.of(context).pushReplacementNamed('/login');
        },
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          ValorDespesasWidget(),
          SizedBox(height: 150),
          BotaoDespesasWidget(),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Gráfico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuração',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GraficoDespesasPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConfHistorico()),
            );
          }
        },
      ),
    );
  }
}

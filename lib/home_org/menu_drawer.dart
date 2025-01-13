import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:AgendaRbc/historicios_relatorio/lista_historico_dispesa.dart';
import 'package:AgendaRbc/servidor_firebase/perfil.dart';

class MenuDrawer extends StatelessWidget {
  final VoidCallback logoutCallback;

  const MenuDrawer({super.key, required this.logoutCallback});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    logoutCallback();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.list_alt_outlined,
              color: Colors.white,
            ),
            title: const Text(
              'Despesas do Mês',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ListaDespesasPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            title: const Text(
              'Editar Despesa',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ListaDespesasPage(editarDespesa: true),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.contact_mail,
              color: Colors.white,
            ),
            title: const Text(
              'Contato',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/contato');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.account_circle,
              color: Colors.white,
            ),
            title: const Text(
              'Perfil',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            title: const Text(
              'Sair',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

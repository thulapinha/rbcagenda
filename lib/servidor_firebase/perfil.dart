import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late String _email;
  late String _username;
  late MaskedTextController _phoneNumberController;
  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _phoneNumberController = MaskedTextController(mask: '(00) 00000-0000');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _username = userData['username'];
        _phoneNumberController.text = userData['phoneNumber'];
        _email = user.email!;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  _saveUserData();
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildTextField(
                      labelText: 'Nome de Usuário',
                      initialValue: _username,
                      onSaved: (value) {
                        _username = value!;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, insira um nome de usuário';
                        }
                        return null;
                      },
                      enabled: _isEditing,
                    ),
                    _buildTextField(
                      labelText: 'Email',
                      initialValue: _email,
                      enabled: false,
                    ),
                    _buildPhoneField(enabled: _isEditing),
                  ],
                ),
              ),
            ),
      backgroundColor: Colors.grey[850],
    );
  }

  Widget _buildTextField({
    required String labelText,
    required String initialValue,
    void Function(String?)? onSaved,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white),
      initialValue: initialValue,
      onSaved: onSaved,
      validator: validator,
      enabled: enabled,
    );
  }

  Widget _buildPhoneField({bool enabled = true}) {
    return TextFormField(
      controller: _phoneNumberController,
      decoration: const InputDecoration(
        labelText: 'Telefone',
        labelStyle: TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Por favor, insira um número de telefone';
        }
        return null;
      },
      enabled: enabled,
    );
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'username': _username,
          'phoneNumber': _phoneNumberController.text,
        });
        await user.updateDisplayName(_username);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados atualizados com sucesso!')),
        );
      }
    }
  }
}

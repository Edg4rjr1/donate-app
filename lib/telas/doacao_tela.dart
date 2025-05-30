import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoacaoTela extends StatefulWidget {
  @override
  _DoacaoTelaState createState() => _DoacaoTelaState();
}

class _DoacaoTelaState extends State<DoacaoTela> {
  final _formKey = GlobalKey<FormState>();
  String nome = '';
  String descricao = '';
  String categoria = 'Roupas';

  List<String> categorias = ['Roupas', 'Comida', 'Brinquedos', 'Outros'];

  bool _isLoading = false;  // Para mostrar loading no botão

  Future<void> _salvarDoacao() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      // Usuário não logado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário não está logado. Faça login para continuar.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('doacoes').add({
        'nome': nome,
        'descricao': descricao,
        'categoria': categoria,
        'timestamp': Timestamp.now(),
        'uid': uid,  // Salva o uid do usuário junto
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Doação salva com sucesso!')),
      );

      Navigator.pop(context, {
       'nome': nome,
       'descricao': descricao,
       'categoria': categoria,
      }); // Fecha a tela após salvar

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar doação: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Doação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome do produto'),
                onSaved: (value) => nome = value!.trim(),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Digite o nome do produto' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrição'),
                onSaved: (value) => descricao = value?.trim() ?? '',
              ),
              DropdownButtonFormField<String>(
                value: categoria,
                items: categorias.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) => setState(() => categoria = value!),
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Salvar Doação'),
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _salvarDoacao();
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class DoacaoTela extends StatefulWidget {
  @override
  _DoacaoTelaState createState() => _DoacaoTelaState();
}

class _DoacaoTelaState extends State<DoacaoTela> {
  final _formKey = GlobalKey<FormState>();
  String nome = '';
  String descricao = '';
  String categoria = 'Roupas';

  List<String> categorias = ['Roupas', 'Alimentos', 'Eletrônicos', 'Livros'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar Doação')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome do produto'),
                onSaved: (value) => nome = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Digite o nome do produto' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Descrição'),
                onSaved: (value) => descricao = value!,
              ),
              DropdownButtonFormField<String>(
                value: categoria,
                items: categorias.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) => setState(() => categoria = value!),
                decoration: InputDecoration(labelText: 'Categoria'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Salvar Doação'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(context, {
                      'nome': nome,
                      'descricao': descricao,
                      'categoria': categoria
                    });
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
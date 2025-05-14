import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> doacoes = [];
  String _categoriaSelecionada = '';
  String _searchText = '';

  void _mostrarCategorias() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        children: ['Roupas', 'Alimentos', 'Eletrônicos', 'Livros'].map((cat) {
          return ListTile(
            title: Text(cat),
            onTap: () {
              Navigator.pop(context);
              setState(() => _categoriaSelecionada = cat);
            },
          );
        }).toList(),
      ),
    );
  }

  void _abrirFormulario() async {
    final novaDoacao = await Navigator.pushNamed(context, '/doacao');

    if (novaDoacao != null && novaDoacao is Map<String, String>) {
      setState(() => doacoes.add(novaDoacao));
    }
  }

  List<Map<String, String>> get _doacoesFiltradas {
    return doacoes.where((d) {
      final matchCategoria = _categoriaSelecionada == '' || d['categoria'] == _categoriaSelecionada;
      final matchBusca = _searchText.isEmpty || d['nome']!.toLowerCase().contains(_searchText.toLowerCase());
      return matchCategoria && matchBusca;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ShareNow - Início'),
        actions: [
          IconButton(icon: Icon(Icons.menu), onPressed: _mostrarCategorias),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Buscar doações...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (valor) {
                setState(() => _searchText = valor);
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: _doacoesFiltradas.isEmpty
                  ? Center(child: Text('Nenhuma doação encontrada'))
                  : ListView.builder(
                      itemCount: _doacoesFiltradas.length,
                      itemBuilder: (context, index) {
                        final item = _doacoesFiltradas[index];
                        return Card(
                          child: ListTile(
                            title: Text(item['nome'] ?? ''),
                            subtitle: Text('${item['descricao']} - ${item['categoria']}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _abrirFormulario,
      ),
    );
  }
}
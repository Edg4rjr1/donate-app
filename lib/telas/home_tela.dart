import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> doacoes = [];
  String _categoriaSelecionada = '';
  String _searchText = '';

  // ─────────── AÇÕES ───────────
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

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // Volta para a tela de login removendo todas as rotas anteriores
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  // ─────────── FILTRO ───────────
  List<Map<String, String>> get _doacoesFiltradas {
    return doacoes.where((d) {
      final matchCategoria = _categoriaSelecionada.isEmpty || d['categoria'] == _categoriaSelecionada;
      final matchBusca = _searchText.isEmpty || d['nome']!.toLowerCase().contains(_searchText.toLowerCase());
      return matchCategoria && matchBusca;
    }).toList();
  }

  // ─────────── UI ───────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShareNow - Início'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Filtrar por categoria',
            onPressed: _mostrarCategorias,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar doações...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (valor) => setState(() => _searchText = valor),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _doacoesFiltradas.isEmpty
                  ? const Center(child: Text('Nenhuma doação encontrada'))
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
        onPressed: _abrirFormulario,
        child: const Icon(Icons.add),
      ),
    );
  }
}
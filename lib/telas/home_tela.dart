import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'doacao_tela.dart';
import 'detalhe_doacao_page.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<DocumentSnapshot> _doacoes = [];
  bool _isLoading = false;
  bool _hasMore = true;
  final int _documentLimit = 10;
  DocumentSnapshot? _lastDocument;

  ScrollController _scrollController = ScrollController();

  String _categoriaSelecionada = 'Todas';

  @override
  void initState() {
    super.initState();
    _getDoacoes();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _getDoacoes();
      }
    });
  }

  Future<void> _getDoacoes() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    Query query = _firestore
        .collection('doac')
        .orderBy('timestamp', descending: true)
        .limit(_documentLimit);

    if (_categoriaSelecionada != 'Todas') {
      query = query.where('categoria', isEqualTo: _categoriaSelecionada);
    }

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final querySnapshot = await query.get();

    if (querySnapshot.docs.length < _documentLimit) {
      _hasMore = false;
    }

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;
      _doacoes.addAll(querySnapshot.docs);
    }

    setState(() => _isLoading = false);
  }

  void _confirmarLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Você deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _auth.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  Future<void> _filtrarPorCategoria(String categoria) async {
    setState(() {
      _categoriaSelecionada = categoria;
      _doacoes.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    await _getDoacoes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShareNow - Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmarLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _categoriaSelecionada,
              onChanged: (value) {
                if (value != null) {
                  _filtrarPorCategoria(value);
                }
              },
              items: const [
                DropdownMenuItem(value: 'Todas', child: Text('Todas')),
                DropdownMenuItem(value: 'Roupas', child: Text('Roupas')),
                DropdownMenuItem(value: 'Comida', child: Text('Comida')),
                DropdownMenuItem(value: 'Brinquedos', child: Text('Brinquedos')),
                DropdownMenuItem(value: 'Outros', child: Text('Outros')),
              ],
            ),
          ),
          Expanded(
            child: _doacoes.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      _doacoes.clear();
                      _lastDocument = null;
                      _hasMore = true;
                      await _getDoacoes();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _doacoes.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _doacoes.length) {
                          return _hasMore
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              : const SizedBox.shrink();
                        }
                        final doacao = _doacoes[index].data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Text(doacao['nome'] ?? 'Sem nome'),
                            subtitle: Text(
                              '${doacao['descricao'] ?? ''}\nCategoria: ${doacao['categoria'] ?? ''}',
                            ),
                            isThreeLine: true,
                            onTap: () {
                             Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalheDoacaoPage(doacao: doacao),
                              ),
                            );
                          },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DoacaoTela()),
          );

          if (resultado != null && resultado is Map<String, dynamic>) {
            await _firestore.collection('doac').add({
              'nome': resultado['nome'],
              'descricao': resultado['descricao'],
              'categoria': resultado['categoria'],
              'timestamp': FieldValue.serverTimestamp(),
            });

            setState(() {
              _doacoes.clear();
              _lastDocument = null;
              _hasMore = true;
            });
            await _getDoacoes();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Nova Doação',
      ),
    );
  }
}
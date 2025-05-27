import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetalheDoacaoPage extends StatelessWidget {
  final Map<String, dynamic> doacao;

  const DetalheDoacaoPage({Key? key, required this.doacao}) : super(key: key);

  Future<String> _buscarNomeUsuario(String uid) async {
    try {
      if (uid.isEmpty) {
        return 'UID do doador ausente';
      }
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        return '${data?['nome'] ?? ''} ${data?['sobrenome'] ?? ''}'.trim();
      }
      return 'Usuário não encontrado';
    } catch (e, stacktrace) {
      print('Erro ao buscar usuário: $e');
      print('Stacktrace: $stacktrace');
      return 'Erro ao buscar usuário';
    }
  }

  static String _formatarData(dynamic timestamp) {
    if (timestamp == null) return "Data desconhecida";
    final date = timestamp.toDate();
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final uidDoador = (doacao['uid'] ?? '') as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Doação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doacao['nome'] ?? 'Sem nome',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Categoria: ${doacao['categoria'] ?? 'N/A'}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "Descrição:\n${doacao['descricao'] ?? 'N/A'}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "Data: ${_formatarData(doacao['timestamp'])}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                // Mostra o nome do doador com FutureBuilder
                FutureBuilder<String>(
                  future: _buscarNomeUsuario(uidDoador),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Carregando nome do doador...');
                    } else if (snapshot.hasError) {
                      return const Text('Erro ao carregar nome do doador');
                    } else {
                      return Text('Doado por: ${snapshot.data}');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
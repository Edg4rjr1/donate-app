import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class CadastroTela extends StatefulWidget {
  const CadastroTela({super.key});

  @override
  State<CadastroTela> createState() => _CadastroTelaState();
}

class _CadastroTelaState extends State<CadastroTela> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController sobrenomeController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController localizacaoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _imagemSelecionada;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(source: ImageSource.camera);

    if (imagem != null) {
      setState(() {
        _imagemSelecionada = File(imagem.path);
      });
    }
  }

  Future<String?> _uploadImagem(String userId) async {
    if (_imagemSelecionada == null) return null;

    final ref = FirebaseStorage.instance.ref().child('usuarios').child('$userId.jpg');
    await ref.putFile(_imagemSelecionada!);
    return await ref.getDownloadURL();
  }

  void _cadastrar() async {
    final nome = nomeController.text.trim();
    final sobrenome = sobrenomeController.text.trim();
    final email = emailController.text.trim();
    final cpf = cpfController.text.trim();
    final cep = cepController.text.trim();
    final localizacao = localizacaoController.text.trim();
    final senha = senhaController.text.trim();
    final confirmarSenha = confirmarSenhaController.text.trim();

    if (nome.isEmpty ||
        sobrenome.isEmpty ||
        email.isEmpty ||
        senha.isEmpty ||
        confirmarSenha.isEmpty ||
        cpf.isEmpty ||
        cep.isEmpty ||
        localizacao.isEmpty) {
      setState(() {
        _errorMessage = 'Preencha todos os campos.';
      });
      return;
    }

    if (senha != confirmarSenha) {
      setState(() {
        _errorMessage = 'As senhas não coincidem.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential =
          await _auth.createUserWithEmailAndPassword(email: email, password: senha);

      if (userCredential.user != null) {
        final user = userCredential.user!;
        final imagemUrl = await _uploadImagem(user.uid);

        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
          'nome': nome,
          'sobrenome': sobrenome,
          'email': email,
          'cpf': cpf,
          'cep': cep,
          'localizacao': localizacao,
          'fotoPerfil': imagemUrl,
          'criadoEm': FieldValue.serverTimestamp(),
        });

        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Erro desconhecido.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    sobrenomeController.dispose();
    emailController.dispose();
    cpfController.dispose();
    cepController.dispose();
    localizacaoController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _selecionarImagem,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imagemSelecionada != null ? FileImage(_imagemSelecionada!) : null,
                child: _imagemSelecionada == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: sobrenomeController,
              decoration: const InputDecoration(labelText: 'Sobrenome'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: cpfController,
              decoration: const InputDecoration(labelText: 'CPF'),
              keyboardType: TextInputType.number,
              inputFormatters: [MaskedInputFormatter('000.000.000-00')],
            ),
            TextField(
              controller: cepController,
              decoration: const InputDecoration(labelText: 'CEP'),
              keyboardType: TextInputType.number,
              inputFormatters: [MaskedInputFormatter('00000-000')],
            ),
            TextField(
              controller: localizacaoController,
              decoration: const InputDecoration(labelText: 'Localização'),
            ),
            TextField(
              controller: senhaController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            TextField(
              controller: confirmarSenhaController,
              decoration: const InputDecoration(labelText: 'Confirmar Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 10),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _cadastrar,
                    child: const Text('Cadastrar'),
                  ),
          ],
        ),
      ),
    );
  }
}
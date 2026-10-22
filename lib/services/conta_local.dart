import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Conta do usuário guardada só neste aparelho (o app é offline).
///
/// A senha nunca é salva: guardamos um hash SHA-256 com sal aleatório.
/// Isso protege a senha em si, mas não substitui um login com servidor;
/// serve para separar o acesso ao app neste aparelho.
class ContaLocal extends ChangeNotifier {
  ContaLocal(this._prefs);

  static const _chaveEmail = 'tasky.conta.email';
  static const _chaveSal = 'tasky.conta.sal';
  static const _chaveHash = 'tasky.conta.hash';
  static const _chaveSessao = 'tasky.conta.sessao';

  static const senhaMinima = 6;

  final SharedPreferences _prefs;

  static Future<ContaLocal> abrir() async =>
      ContaLocal(await SharedPreferences.getInstance());

  String? get email => _texto(_chaveEmail);
  bool get temConta => email != null && _texto(_chaveHash) != null;
  bool get logado => temConta && _prefs.getBool(_chaveSessao) == true;

  /// Cria a conta e já entra. Retorna uma mensagem de erro, ou null.
  Future<String?> cadastrar(String email, String senha) async {
    final e = _normalizar(email);
    if (temConta && this.email != e) {
      return 'Já existe uma conta neste aparelho. Entre com ela.';
    }
    if (temConta) return 'Este e-mail já tem conta. Use a aba Entrar.';
    final sal = base64Url.encode(
      List.generate(16, (_) => Random.secure().nextInt(256)),
    );
    await _prefs.setString(_chaveEmail, e);
    await _prefs.setString(_chaveSal, sal);
    await _prefs.setString(_chaveHash, _hash(sal, senha));
    await _prefs.setBool(_chaveSessao, true);
    notifyListeners();
    return null;
  }

  /// Entra na conta. Retorna uma mensagem de erro, ou null.
  Future<String?> entrar(String email, String senha) async {
    if (!temConta) return 'Nenhuma conta neste aparelho. Crie uma conta.';
    final sal = _texto(_chaveSal) ?? '';
    if (this.email != _normalizar(email) ||
        _texto(_chaveHash) != _hash(sal, senha)) {
      return 'E-mail ou senha incorretos.';
    }
    await _prefs.setBool(_chaveSessao, true);
    notifyListeners();
    return null;
  }

  Future<void> sair() async {
    await _prefs.setBool(_chaveSessao, false);
    notifyListeners();
  }

  static String? validarEmail(String? v) {
    final e = v?.trim() ?? '';
    if (e.isEmpty) return 'Informe seu e-mail.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)) {
      return 'Confira o e-mail digitado.';
    }
    return null;
  }

  static String? validarSenha(String? v) {
    if (v == null || v.isEmpty) return 'Informe sua senha.';
    if (v.length < senhaMinima) {
      return 'A senha precisa de pelo menos $senhaMinima caracteres.';
    }
    return null;
  }

  String? _texto(String chave) {
    final v = _prefs.get(chave);
    return v is String && v.isNotEmpty ? v : null;
  }

  static String _normalizar(String email) => email.trim().toLowerCase();

  static String _hash(String sal, String senha) =>
      sha256.convert(utf8.encode('$sal:$senha')).toString();
}

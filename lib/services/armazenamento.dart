import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/progresso.dart';
import '../models/regras_xp.dart';
import '../models/tarefa.dart';
import '../models/trilha.dart';

/// Dados salvos no aparelho.
class DadosSalvos {
  const DadosSalvos({
    this.tarefas = const [],
    this.trilhaId,
    this.progresso = const Progresso(),
    this.trilhasPersonalizadas = const {},
    this.diasAtivos = const [],
    this.ultimoCombo,
  });

  final List<Tarefa> tarefas;
  final String? trilhaId;
  final Progresso progresso;

  /// Tarefas editadas pelo usuário, por id de trilha.
  final Map<String, List<TarefaModelo>> trilhasPersonalizadas;

  /// Dias (aaaa-mm-dd) com ao menos uma tarefa concluída.
  final List<String> diasAtivos;

  /// Último dia em que um combo deu bônus.
  final String? ultimoCombo;
}

/// Lê e grava os dados do Tasky com shared_preferences.
/// Dados ausentes ou corrompidos viram valores padrão, sem derrubar o app.
class Armazenamento {
  Armazenamento(this._prefs);

  static const _chaveTarefas = 'tasky.tarefas';
  static const _chaveTrilha = 'tasky.trilha';
  static const _chaveXp = 'tasky.xp';
  static const _chavePersonalizadas = 'tasky.trilhas.personalizadas';
  static const _chaveDias = 'tasky.dias';
  static const _chaveCombo = 'tasky.combo';

  final SharedPreferences _prefs;

  static Future<Armazenamento> abrir() async =>
      Armazenamento(await SharedPreferences.getInstance());

  DadosSalvos carregar() {
    final xp = _prefs.get(_chaveXp);
    final trilha = _prefs.get(_chaveTrilha);
    return DadosSalvos(
      tarefas: _lerTarefas(),
      trilhaId: trilha is String && trilha.isNotEmpty ? trilha : null,
      progresso: Progresso(xp: xp is int ? xp.clamp(0, RegrasXp.xpMaximo) : 0),
      trilhasPersonalizadas: _lerPersonalizadas(),
      diasAtivos: _lerDias(),
      ultimoCombo: _prefs.get(_chaveCombo) is String
          ? _prefs.get(_chaveCombo) as String
          : null,
    );
  }

  List<String> _lerDias() {
    final bruto = _prefs.get(_chaveDias);
    return bruto is List ? bruto.whereType<String>().toList() : [];
  }

  Map<String, List<TarefaModelo>> _lerPersonalizadas() {
    final bruto = _prefs.get(_chavePersonalizadas);
    if (bruto is! String) return {};
    try {
      final mapa = jsonDecode(bruto);
      if (mapa is! Map) return {};
      return {
        for (final e in mapa.entries)
          if (e.key is String && e.value is List)
            e.key as String: (e.value as List)
                .map(TarefaModelo.fromJson)
                .whereType<TarefaModelo>()
                .toList(),
      };
    } on FormatException {
      return {};
    }
  }

  List<Tarefa> _lerTarefas() {
    final bruto = _prefs.get(_chaveTarefas);
    if (bruto is! String) return [];
    try {
      final lista = jsonDecode(bruto);
      if (lista is! List) return [];
      // Itens inválidos são descartados; os válidos são mantidos.
      return lista.map(Tarefa.fromJson).whereType<Tarefa>().toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> salvarTarefas(List<Tarefa> tarefas) => _prefs.setString(
    _chaveTarefas,
    jsonEncode(tarefas.map((t) => t.toJson()).toList()),
  );

  Future<void> salvarTrilha(String? trilhaId) => trilhaId == null
      ? _prefs.remove(_chaveTrilha)
      : _prefs.setString(_chaveTrilha, trilhaId);

  Future<void> salvarProgresso(Progresso progresso) =>
      _prefs.setInt(_chaveXp, progresso.xp);

  Future<void> salvarCombo(List<String> dias, String? ultimoCombo) async {
    await _prefs.setStringList(_chaveDias, dias);
    if (ultimoCombo != null) await _prefs.setString(_chaveCombo, ultimoCombo);
  }

  Future<void> salvarTrilhasPersonalizadas(
    Map<String, List<TarefaModelo>> trilhas,
  ) => _prefs.setString(
    _chavePersonalizadas,
    jsonEncode({
      for (final e in trilhas.entries)
        e.key: e.value.map((m) => m.toJson()).toList(),
    }),
  );
}

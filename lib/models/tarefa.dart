/// Uma tarefa do usuário, personalizada ou vinda de uma trilha.
class Tarefa {
  const Tarefa({
    required this.id,
    required this.titulo,
    this.observacao,
    this.categoria,
    this.data,
    this.xp = 10,
    this.concluida = false,
    this.trilhaId,
    this.xpConcedido = false,
    this.penalizada = false,
  });

  final String id;
  final String titulo;
  final String? observacao;
  final String? categoria;
  final DateTime? data;
  final int xp;
  final bool concluida;

  /// Id da trilha de origem; null para tarefas personalizadas.
  final String? trilhaId;

  /// Marca que o XP desta tarefa já foi somado, para não duplicar
  /// quando ela for reaberta e concluída de novo.
  final bool xpConcedido;

  /// Marca que o atraso desta tarefa já tirou XP (só acontece uma vez).
  final bool penalizada;

  bool get veioDeTrilha => trilhaId != null;

  /// Atrasada: tem data anterior a hoje e ainda não foi concluída.
  /// Muito atraso pode tirar XP (ver RegrasXp.diasParaPenalizar).
  bool atrasada([DateTime? agora]) {
    if (concluida || data == null) return false;
    final hoje = _soData(agora ?? DateTime.now());
    return _soData(data!).isBefore(hoje);
  }

  /// Dias inteiros de atraso (0 se não estiver atrasada).
  int diasDeAtraso([DateTime? agora]) {
    if (!atrasada(agora)) return 0;
    return _soData(agora ?? DateTime.now()).difference(_soData(data!)).inDays;
  }

  Tarefa copyWith({
    String? titulo,
    String? observacao,
    String? categoria,
    DateTime? data,
    int? xp,
    bool? concluida,
    bool? xpConcedido,
    bool? penalizada,
    bool limparObservacao = false,
    bool limparCategoria = false,
    bool limparData = false,
  }) {
    return Tarefa(
      id: id,
      titulo: titulo ?? this.titulo,
      observacao: limparObservacao ? null : (observacao ?? this.observacao),
      categoria: limparCategoria ? null : (categoria ?? this.categoria),
      data: limparData ? null : (data ?? this.data),
      xp: xp ?? this.xp,
      concluida: concluida ?? this.concluida,
      trilhaId: trilhaId,
      xpConcedido: xpConcedido ?? this.xpConcedido,
      penalizada: penalizada ?? this.penalizada,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    if (observacao != null) 'observacao': observacao,
    if (categoria != null) 'categoria': categoria,
    if (data != null) 'data': data!.toIso8601String(),
    'xp': xp,
    'concluida': concluida,
    if (trilhaId != null) 'trilhaId': trilhaId,
    'xpConcedido': xpConcedido,
    'penalizada': penalizada,
  };

  /// Retorna null se faltarem campos obrigatórios (id, título).
  static Tarefa? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final titulo = json['titulo'];
    if (id is! String || id.isEmpty || titulo is! String) return null;

    final xp = json['xp'];
    final dataTxt = json['data'];
    return Tarefa(
      id: id,
      titulo: titulo,
      observacao: _textoOuNull(json['observacao']),
      categoria: _textoOuNull(json['categoria']),
      data: dataTxt is String ? DateTime.tryParse(dataTxt) : null,
      xp: xp is int && xp >= 0 ? xp : 10,
      concluida: json['concluida'] == true,
      trilhaId: _textoOuNull(json['trilhaId']),
      xpConcedido: json['xpConcedido'] == true,
      penalizada: json['penalizada'] == true,
    );
  }
}

String? _textoOuNull(Object? v) => v is String && v.isNotEmpty ? v : null;

DateTime _soData(DateTime d) => DateTime(d.year, d.month, d.day);

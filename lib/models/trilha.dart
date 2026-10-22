import 'regras_xp.dart';

/// Modelo de tarefa que uma trilha oferece.
class TarefaModelo {
  const TarefaModelo({required this.titulo, this.categoria, this.xp = 10});

  final String titulo;
  final String? categoria;
  final int xp;

  TarefaModelo comTitulo(String novo) =>
      TarefaModelo(titulo: novo, categoria: categoria, xp: xp);

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    if (categoria != null) 'categoria': categoria,
    'xp': xp,
  };

  /// Retorna null se o título estiver ausente ou em branco.
  static TarefaModelo? fromJson(Object? json) {
    if (json is! Map) return null;
    final titulo = json['titulo'];
    if (titulo is! String || titulo.trim().isEmpty) return null;
    final categoria = json['categoria'];
    final xp = json['xp'];
    return TarefaModelo(
      titulo: titulo,
      categoria: categoria is String && categoria.isNotEmpty ? categoria : null,
      xp: xp is int && xp >= 0 ? xp : 10,
    );
  }
}

/// Trilha predefinida. As trilhas ficam no código; o que é salvo é o id
/// da trilha selecionada e as tarefas personalizadas de cada trilha.
class Trilha {
  const Trilha({
    required this.id,
    required this.nome,
    required this.descricao,
    this.duracao = '',
    this.dificuldade = Dificuldade.leve,
    this.tarefas = const [],
  });

  final String id;
  final String nome;
  final String descricao;

  /// Duração sugerida, só como referência (ex.: "7 dias").
  final String duracao;

  /// Define o XP de cada tarefa e quanto se perde com atraso.
  final Dificuldade dificuldade;
  final List<TarefaModelo> tarefas;
}

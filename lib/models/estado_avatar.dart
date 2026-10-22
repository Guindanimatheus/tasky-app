import 'regras_xp.dart';

/// Estados do avatar Tasky (documentação, seção 6), do mais crítico ao
/// mais positivo.
///
/// A regra fica toda aqui: para ajustar as faixas, mude só [xpMinimo].
/// O estado acompanha o XP: sobe com tarefas concluídas e pode cair
/// quando tarefas muito atrasadas tiram XP (ver [RegrasXp]).
enum EstadoAvatar {
  procrastinador(
    numero: 1,
    nome: 'O Procrastinador',
    palavrasChave: ['Excesso', 'Estagnação', 'Descuido'],
    xpMinimo: 0,
    frase:
        'Você se tornou um mestre em procrastinar. '
        'Vamos dar a volta por cima!',
  ),
  piorando(
    numero: 2,
    nome: 'Piorando',
    palavrasChave: ['Desorganização', 'Alerta', 'Risco'],
    xpMinimo: 200,
    frase: 'Atenção antes que piore.',
  ),
  neutro(
    numero: 3,
    nome: 'Neutro',
    palavrasChave: ['Equilíbrio', 'Flexibilidade', 'Moderação'],
    xpMinimo: 400,
    frase: 'Podemos melhorar.',
  ),
  indoBem(
    numero: 4,
    nome: 'Indo bem',
    palavrasChave: ['Evolução', 'Equilíbrio', 'Motivação'],
    xpMinimo: 600,
    frase: 'Pequenos passos, grandes resultados.',
  ),
  disciplinado(
    numero: 5,
    nome: 'Disciplinado',
    palavrasChave: ['Foco', 'Constância', 'Resultados'],
    xpMinimo: 800,
    frase: 'Disciplina gera resultados.',
  );

  const EstadoAvatar({
    required this.numero,
    required this.nome,
    required this.palavrasChave,
    required this.xpMinimo,
    required this.frase,
  });

  /// Posição de 1 a 5, exibida junto do nome (não depende de cor).
  final int numero;
  final String nome;
  final List<String> palavrasChave;

  /// XP a partir do qual este estado começa.
  final int xpMinimo;
  final String frase;

  /// Estado correspondente ao XP total.
  static EstadoAvatar paraXp(int xp) {
    var atual = values.first;
    for (final e in values) {
      if (xp >= e.xpMinimo) atual = e;
    }
    return atual;
  }

  EstadoAvatar? get proximo =>
      index + 1 < values.length ? values[index + 1] : null;

  /// XP em que este estado termina.
  int get xpFinal => proximo?.xpMinimo ?? RegrasXp.xpMaximo;

  /// Fração do caminho até o fim deste estado.
  double progresso(int xp) =>
      ((xp - xpMinimo) / (xpFinal - xpMinimo)).clamp(0.0, 1.0);
}

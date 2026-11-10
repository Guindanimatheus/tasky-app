/// Todas as regras de XP do Tasky ficam aqui, para ajustar num só lugar.
abstract final class RegrasXp {
  /// O XP vai de 0 a [xpMaximo].
  static const xpMaximo = 1000;

  /// XP de uma tarefa criada pelo usuário.
  static const xpTarefaPropria = 10;

  /// Uma tarefa com data só perde XP depois de tantos dias de atraso.
  static const diasParaPenalizar = 2;

  /// Combo: dias seguidos com ao menos uma tarefa concluída.
  static const diasCombo = 5;
  static const bonusCombo = 100;
}

/// Dificuldade da trilha: quanto cada tarefa vale e quanto se perde
/// quando ela fica muito atrasada (fração do que ela daria).
enum Dificuldade {
  leve(nome: 'Fácil', xpPorTarefa: 10, fracaoPerda: 0),
  facilModerada(nome: 'Fácil a moderada', xpPorTarefa: 11, fracaoPerda: 0.25),
  media(nome: 'Moderada', xpPorTarefa: 12, fracaoPerda: 0.5),
  dificil(nome: 'Difícil', xpPorTarefa: 15, fracaoPerda: 1),
  avancada(nome: 'Avançada', xpPorTarefa: 18, fracaoPerda: 1);

  const Dificuldade({
    required this.nome,
    required this.xpPorTarefa,
    required this.fracaoPerda,
  });

  final String nome;
  final int xpPorTarefa;
  final double fracaoPerda;

  /// XP perdido por uma tarefa que vale [xp] e ficou muito atrasada.
  int perdaPara(int xp) => (xp * fracaoPerda).round();
}

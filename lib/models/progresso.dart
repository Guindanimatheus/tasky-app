import 'regras_xp.dart';

/// Progresso do usuário: XP acumulado (0 a [RegrasXp.xpMaximo]) e nível
/// derivado dele.
class Progresso {
  const Progresso({this.xp = 0});

  static const xpPorNivel = 100;

  /// Sempre entre 0 e [RegrasXp.xpMaximo].
  final int xp;

  int get nivel => xp ~/ xpPorNivel + 1;

  /// XP dentro do nível atual (0 a [xpPorNivel] - 1).
  int get xpNoNivel => xp % xpPorNivel;

  /// Fração do nível atual, de 0.0 a 1.0, para barras de progresso.
  double get fracaoNivel => xpNoNivel / xpPorNivel;

  Progresso ganhar(int pontos) => pontos <= 0
      ? this
      : Progresso(xp: (xp + pontos).clamp(0, RegrasXp.xpMaximo));

  Progresso perder(int pontos) => pontos <= 0
      ? this
      : Progresso(xp: (xp - pontos).clamp(0, RegrasXp.xpMaximo));
}

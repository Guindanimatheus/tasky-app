import 'package:flutter/material.dart';

import '../models/estado_avatar.dart';
import '../theme/tasky_theme.dart';
import 'tasky_avatar_scene.dart';

/// Cor temática de cada estado (documentação, seção 6).
Color corDoEstado(EstadoAvatar e) => switch (e) {
  EstadoAvatar.procrastinador => TaskyColors.vermelho,
  EstadoAvatar.piorando => TaskyColors.amarelo,
  EstadoAvatar.neutro => TaskyColors.dourado,
  EstadoAvatar.indoBem => TaskyColors.verde,
  EstadoAvatar.disciplinado => TaskyColors.roxoClaro,
};

/// Cartão de status do avatar Tasky, no formato das telas 03–07 do Figma:
/// cabeçalho com nome, palavras-chave e sinal de nível; cena animada
/// ([TaskyAvatarScene]); citação; e barra de progresso até o próximo
/// estado.
///
/// A cena fica fixa na árvore: quando o XP muda de faixa, só o `mood`
/// dela é atualizado e os textos trocam com uma transição.
class AvatarTasky extends StatelessWidget {
  const AvatarTasky({
    super.key,
    required this.xp,
    this.tamanho = 200,
    this.mostrarTexto = true,
  });

  final int xp;

  /// Lado da área do mascote.
  final double tamanho;

  /// Exibe cabeçalho, citação e barra de progresso.
  final bool mostrarTexto;

  @override
  Widget build(BuildContext context) {
    final estado = EstadoAvatar.paraXp(xp);
    final cor = corDoEstado(estado);
    final s = tamanho;

    final moldura = AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: EdgeInsets.only(top: s * 0.2, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cor, width: 2),
        boxShadow: [
          BoxShadow(color: cor.withValues(alpha: 0.35), blurRadius: 14),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cor.withValues(alpha: 0.28), TaskyColors.fundo],
        ),
      ),
      child: Center(
        child: Semantics(
          button: true,
          label: 'Avatar Tasky. Estado ${estado.numero} de 5: ${estado.nome}.',
          hint: 'Toque para ver uma reação.',
          child: TaskyAvatarScene(mood: estado.index, tamanho: s),
        ),
      ),
    );

    if (!mostrarTexto) return moldura;

    final tema = Theme.of(context);
    Widget trocar(Widget filho) => AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(key: ValueKey(estado), child: filho),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        trocar(_Cabecalho(estado: estado, cor: cor)),
        const SizedBox(height: 12),
        moldura,
        const SizedBox(height: 12),
        trocar(
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cor.withValues(alpha: 0.6)),
            ),
            child: Text(
              '“${estado.frase}”',
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          label: estado.proximo == null
              ? 'Estado máximo alcançado'
              : 'Progresso até ${estado.proximo!.nome}: '
                    '${(estado.progresso(xp) * 100).round()} por cento',
          excludeSemantics: true,
          child: LinearProgressIndicator(
            value: estado.progresso(xp),
            minHeight: 10,
            color: cor,
            backgroundColor: TaskyColors.superficieClara.withValues(
              alpha: 0.85,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}

/// Cabeçalho: ícone, nome em pixel, palavras-chave e sinal de nível.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.estado, required this.cor});

  final EstadoAvatar estado;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: cor, width: 2),
          ),
          child: Icon(
            estado == EstadoAvatar.indoBem ? Icons.eco : Icons.pets,
            size: 18,
            color: cor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                estado.nome.toUpperCase(),
                style: const TextStyle(
                  fontFamily: kFontePixel,
                  fontSize: 12,
                  height: 1.4,
                  color: TaskyColors.superficieClara,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                estado.palavrasChave.join(' • '),
                style: tema.textTheme.bodySmall?.copyWith(color: cor),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _SinalNivel(nivel: estado.numero, cor: cor),
      ],
    );
  }
}

/// Barrinhas de sinal: o número de barras preenchidas é o nível (1–5),
/// então a posição não depende só de cor.
class _SinalNivel extends StatelessWidget {
  const _SinalNivel({required this.nivel, required this.cor});

  final int nivel;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Nível $nivel de 5',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 1; i <= 5; i++)
            Container(
              margin: const EdgeInsets.only(left: 2),
              width: 5,
              height: 5.0 + i * 3,
              decoration: BoxDecoration(
                color: i <= nivel ? cor : Colors.transparent,
                border: Border.all(
                  color: i <= nivel ? cor : TaskyColors.textoSuave,
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }
}

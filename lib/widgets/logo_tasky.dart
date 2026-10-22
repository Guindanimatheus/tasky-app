import 'package:flutter/material.dart';

import '../theme/tasky_theme.dart';

/// Coração em pixel art do logotipo: vermelho em cima (ação) e verde
/// embaixo (evolução), como no MIV.
class CoracaoPixel extends StatelessWidget {
  const CoracaoPixel({super.key, this.tamanho = 96});

  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(tamanho, tamanho * _linhas.length / _linhas[0].length),
        painter: _PintorCoracao(),
      ),
    );
  }
}

/// R = vermelho, D = vermelho escuro, G = verde, W = brilho.
const _linhas = [
  '..RRR...RRR..',
  '.RWWRR.RRRRR.',
  'RRWRRRRRRRRRR',
  'RRRRRRRRRRRRR',
  'RRRRRRRRRRRRR',
  'DDDDDDDDDDDDD',
  '.GGGGGGGGGGG.',
  '..GGGGGGGGG..',
  '...GGGGGGG...',
  '....GGGGG....',
  '.....GGG.....',
  '......G......',
];

class _PintorCoracao extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final px = size.width / _linhas[0].length;
    for (var y = 0; y < _linhas.length; y++) {
      for (var x = 0; x < _linhas[y].length; x++) {
        final cor = switch (_linhas[y][x]) {
          'R' => TaskyColors.vermelho,
          'D' => const Color(0xFFB0221F),
          'G' => TaskyColors.verde,
          'W' => Colors.white,
          _ => null,
        };
        if (cor == null) continue;
        // +0.5 evita frestas entre os pixels.
        canvas.drawRect(
          Rect.fromLTWH(x * px, y * px, px + 0.5, px + 0.5),
          Paint()..color = cor,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PintorCoracao old) => false;
}

/// Coração + "TASKY" + slogan, usado na splash.
class LogoTasky extends StatelessWidget {
  const LogoTasky({super.key, this.tamanho = 120});

  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Tasky. Viva suas escolhas.',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CoracaoPixel(tamanho: tamanho),
            SizedBox(height: tamanho * 0.25),
            Text(
              'TASKY',
              style: TextStyle(
                fontFamily: kFontePixel,
                fontSize: tamanho * 0.28,
                color: TaskyColors.superficieClara,
              ),
            ),
            SizedBox(height: tamanho * 0.1),
            Text(
              'VIVA SUAS ESCOLHAS',
              style: TextStyle(
                fontFamily: kFontePixel,
                fontSize: tamanho * 0.075,
                color: TaskyColors.verde,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

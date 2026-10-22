import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/estado_avatar.dart';
import '../theme/tasky_theme.dart';

/// Pose da cabeça, separada do corpo: giro e deslocamento a partir do
/// pescoço, direção do olhar (-1 a 1 em x e y), piscada e "encarando"
/// (pupilas redondas, olhando para quem usa o celular).
typedef PoseCabeca = ({
  double giro,
  double dx,
  double dy,
  Offset olhar,
  bool piscar,
  bool encarando,
});

const PoseCabeca poseNeutra = (
  giro: 0,
  dx: 0,
  dy: 0,
  olhar: Offset.zero,
  piscar: false,
  encarando: false,
);

/// PRÉVIA TEMPORÁRIA do mascote, desenhada com formas até existir o
/// arquivo Rive em camadas (assets/mascote/tasky_scene.riv).
/// Cabeça e corpo são camadas separadas: a [pose] move só a cabeça.
class PintorGatoProvisorio extends CustomPainter {
  PintorGatoProvisorio({
    required this.estado,
    required this.t,
    required this.reagindo,
    this.pose = poseNeutra,
  }) : soParticulas = false;

  PintorGatoProvisorio.soParticulas({required this.t})
    : estado = EstadoAvatar.disciplinado,
      reagindo = true,
      soParticulas = true,
      pose = poseNeutra;

  final EstadoAvatar estado;
  final double t;
  final bool reagindo;
  final bool soParticulas;
  final PoseCabeca pose;

  static const _pelo = Color(0xFFE07B39);
  static const _peloEscuro = Color(0xFFB85A22);
  static const _peloClaro = Color(0xFFFFF1E0);
  static const _orelhaDentro = Color(0xFFF4A7A0);
  static const _moletom = Color(0xFF1C1C22);
  static const _contorno = Color(0xFF2A1A12);
  static const _iris = Color(0xFFF2B33D);

  late double _s;

  Offset _p(double x, double y) => Offset(x * _s, y * _s);

  /// Aplica a pose da cabeça girando em torno do pescoço.
  void _transformarCabeca(Canvas canvas) {
    final pescoco = _p(0.5, 0.7);
    canvas.translate(pescoco.dx + pose.dx * _s, pescoco.dy + pose.dy * _s);
    canvas.rotate(pose.giro);
    canvas.translate(-pescoco.dx, -pescoco.dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _s = size.width;
    final arco = reagindo ? math.sin(math.pi * t) : 0.0;

    if (reagindo && estado == EstadoAvatar.disciplinado) _particulas(canvas);
    if (soParticulas) return;

    final contorno = Paint()
      ..color = _contorno
      ..style = PaintingStyle.stroke
      ..strokeWidth = _s * 0.012
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final capuz = estado.index <= EstadoAvatar.piorando.index;

    // Capuz levantado nos estados 1 e 2.
    if (capuz) {
      canvas.save();
      _transformarCabeca(canvas);
      canvas.drawOval(
        Rect.fromCenter(
          center: _p(0.5, 0.45),
          width: _s * 0.76,
          height: _s * 0.7,
        ),
        Paint()..color = _moletom,
      );
      canvas.restore();
    }

    // Corpo com moletom e cordões.
    final corpo = RRect.fromRectAndRadius(
      Rect.fromLTRB(_s * 0.18, _s * 0.7, _s * 0.82, _s * 1.04),
      Radius.circular(_s * 0.16),
    );
    canvas.drawRRect(corpo, Paint()..color = _moletom);
    final cordao = Paint()
      ..color = _peloClaro
      ..strokeWidth = _s * 0.012
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(_p(0.45, 0.74), _p(0.44, 0.86), cordao);
    canvas.drawLine(_p(0.55, 0.74), _p(0.56, 0.86), cordao);
    // Gatinho estampado no peito.
    _gatinhoEstampa(canvas, _p(0.66, 0.88), _s * 0.035);

    // Fone no pescoço nos estados 3 a 5.
    if (!capuz) {
      canvas.drawArc(
        Rect.fromCenter(
          center: _p(0.5, 0.68),
          width: _s * 0.5,
          height: _s * 0.16,
        ),
        0.1,
        math.pi - 0.2,
        false,
        Paint()
          ..color = const Color(0xFF3A3A44)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _s * 0.04,
      );
    }

    // Camada da cabeça: orelhas, cabeça, franja e rosto.
    canvas.save();
    _transformarCabeca(canvas);

    // Orelhas (no estado 2, levantam no susto).
    final ergue = estado == EstadoAvatar.piorando ? arco * 0.04 : 0.0;
    _orelha(canvas, [
      _p(0.27, 0.38),
      _p(0.29, 0.12 - ergue),
      _p(0.45, 0.28),
    ], contorno);
    _orelha(canvas, [
      _p(0.73, 0.38),
      _p(0.71, 0.12 - ergue),
      _p(0.55, 0.28),
    ], contorno);

    // Cabeça.
    final cabeca = Rect.fromCenter(
      center: _p(0.5, 0.48),
      width: _s * 0.56,
      height: _s * 0.46,
    );
    canvas.drawOval(cabeca, Paint()..color = _pelo);
    canvas.drawOval(cabeca, contorno);

    // Franja espetada.
    final franja = Path()
      ..moveTo(_s * 0.34, _s * 0.3)
      ..lineTo(_s * 0.42, _s * 0.4)
      ..lineTo(_s * 0.45, _s * 0.31)
      ..lineTo(_s * 0.52, _s * 0.42)
      ..lineTo(_s * 0.56, _s * 0.31)
      ..lineTo(_s * 0.62, _s * 0.39)
      ..lineTo(_s * 0.66, _s * 0.3)
      ..close();
    canvas.drawPath(franja, Paint()..color = _peloEscuro);

    // Focinho claro e nariz.
    canvas.drawOval(
      Rect.fromCenter(
        center: _p(0.5, 0.6),
        width: _s * 0.26,
        height: _s * 0.15,
      ),
      Paint()..color = _peloClaro,
    );
    final nariz = Path()
      ..moveTo(_s * 0.48, _s * 0.55)
      ..lineTo(_s * 0.52, _s * 0.55)
      ..lineTo(_s * 0.5, _s * 0.575)
      ..close();
    canvas.drawPath(nariz, Paint()..color = const Color(0xFFE58C8C));

    _rosto(canvas, arco, contorno);
    canvas.restore();

    _extras(canvas, arco);
  }

  void _orelha(Canvas canvas, List<Offset> pts, Paint contorno) {
    final fora = Path()..addPolygon(pts, true);
    canvas.drawPath(fora, Paint()..color = _pelo);
    canvas.drawPath(fora, contorno);
    final centro = Offset(
      (pts[0].dx + pts[1].dx + pts[2].dx) / 3,
      (pts[0].dy + pts[1].dy + pts[2].dy) / 3,
    );
    final dentro = Path()
      ..addPolygon([for (final p in pts) Offset.lerp(centro, p, 0.55)!], true);
    canvas.drawPath(dentro, Paint()..color = _orelhaDentro);
  }

  /// Olho com pálpebra: [fechado] vai de 0 (aberto) a 1 (fechado).
  void _olho(
    Canvas canvas,
    Offset c,
    double fechado,
    Paint contorno, {
    bool pupilaRedonda = false,
  }) {
    final w = _s * 0.1;
    final h = _s * 0.1;
    if (pose.piscar) fechado = 1;
    if (pose.encarando) {
      fechado = fechado.clamp(0.0, 0.15);
      pupilaRedonda = true;
    }
    if (fechado >= 0.95) {
      canvas.drawLine(c - Offset(w / 2, 0), c + Offset(w / 2, 0), contorno);
      return;
    }
    final olho = Rect.fromCenter(center: c, width: w, height: h);
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(
        olho.left - 2,
        olho.top + h * fechado,
        olho.right + 2,
        olho.bottom + 2,
      ),
    );
    canvas.drawOval(olho, Paint()..color = _iris);
    final centro =
        c + Offset(pose.olhar.dx * w * 0.22, pose.olhar.dy * h * 0.2);
    final pupila = pupilaRedonda
        ? Rect.fromCenter(center: centro, width: w * 0.36, height: h * 0.36)
        : Rect.fromCenter(center: centro, width: w * 0.22, height: h * 0.7);
    canvas.drawOval(pupila, Paint()..color = _contorno);
    canvas.drawCircle(
      c + Offset(-w * 0.18, -h * 0.18),
      w * 0.1,
      Paint()..color = Colors.white,
    );
    canvas.drawOval(olho, contorno);
    canvas.restore();
    // Linha da pálpebra.
    final y = olho.top + h * fechado;
    canvas.drawLine(
      Offset(olho.left - w * 0.05, y),
      Offset(olho.right + w * 0.05, y),
      contorno,
    );
  }

  /// Olho feliz fechado (^).
  void _olhoFeliz(Canvas canvas, Offset c, Paint contorno) {
    canvas.drawArc(
      Rect.fromCenter(
        center: c + Offset(0, _s * 0.015),
        width: _s * 0.1,
        height: _s * 0.08,
      ),
      math.pi,
      math.pi,
      false,
      contorno,
    );
  }

  void _rosto(Canvas canvas, double arco, Paint contorno) {
    final oE = _p(0.39, 0.47);
    final oD = _p(0.61, 0.47);
    final boca = _p(0.5, 0.61);
    final traco = Paint()
      ..color = _contorno
      ..style = PaintingStyle.stroke
      ..strokeWidth = _s * 0.012
      ..strokeCap = StrokeCap.round;

    switch (estado) {
      case EstadoAvatar.procrastinador:
        // Sonolento, com olheiras; no toque, fecha os olhos e boceja.
        final f = 0.72 + 0.28 * arco;
        _olho(canvas, oE, f, contorno);
        _olho(canvas, oD, f, contorno);
        for (final o in [oE, oD]) {
          canvas.drawArc(
            Rect.fromCenter(
              center: o + Offset(0, _s * 0.06),
              width: _s * 0.08,
              height: _s * 0.03,
            ),
            0,
            math.pi,
            false,
            traco..color = _peloEscuro,
          );
        }
        traco.color = _contorno;
        if (arco > 0.05) {
          canvas.drawOval(
            Rect.fromCenter(
              center: boca + Offset(0, _s * 0.01),
              width: _s * 0.07,
              height: _s * 0.1 * arco,
            ),
            Paint()..color = const Color(0xFF5A1E1E),
          );
        } else {
          canvas.drawLine(
            boca - Offset(_s * 0.03, 0),
            boca + Offset(_s * 0.03, 0),
            traco,
          );
        }
      case EstadoAvatar.piorando:
        // Desconfiado, sobrancelhas tensas; no toque, arregala os olhos.
        final f = 0.4 * (1 - arco);
        _olho(canvas, oE, f, contorno, pupilaRedonda: arco > 0.3);
        _olho(canvas, oD, f, contorno, pupilaRedonda: arco > 0.3);
        final subir = arco * _s * 0.03;
        canvas.drawLine(
          oE + Offset(-_s * 0.05, -_s * 0.07 - subir),
          oE + Offset(_s * 0.05, -_s * 0.05 - subir),
          traco,
        );
        canvas.drawLine(
          oD + Offset(-_s * 0.05, -_s * 0.05 - subir),
          oD + Offset(_s * 0.05, -_s * 0.07 - subir),
          traco,
        );
        if (arco > 0.2) {
          canvas.drawOval(
            Rect.fromCenter(
              center: boca + Offset(0, _s * 0.01),
              width: _s * 0.04,
              height: _s * 0.05,
            ),
            traco,
          );
        } else {
          canvas.drawArc(
            Rect.fromCenter(
              center: boca + Offset(0, _s * 0.02),
              width: _s * 0.08,
              height: _s * 0.04,
            ),
            math.pi,
            math.pi,
            false,
            traco,
          );
        }
      case EstadoAvatar.neutro:
        // Tranquilo; no toque, pisca e acena com a patinha.
        final piscando = reagindo && t > 0.3 && t < 0.55;
        _olho(canvas, oE, piscando ? 1 : 0.4, contorno);
        _olho(canvas, oD, piscando ? 1 : 0.4, contorno);
        _bocaW(canvas, boca, traco, 0);
      case EstadoAvatar.indoBem:
        // Atento e contente; no toque, sorri de olhos fechados.
        if (arco > 0.15) {
          _olhoFeliz(canvas, oE, contorno);
          _olhoFeliz(canvas, oD, contorno);
        } else {
          _olho(canvas, oE, 0.2, contorno);
          _olho(canvas, oD, 0.2, contorno);
        }
        _bocaW(canvas, boca, traco, 0.6 + arco);
      case EstadoAvatar.disciplinado:
        // Confiante; no toque, comemora de olhos fechados e boca aberta.
        if (arco > 0.15) {
          _olhoFeliz(canvas, oE, contorno);
          _olhoFeliz(canvas, oD, contorno);
          final sorriso = Path()
            ..moveTo(boca.dx - _s * 0.05, boca.dy - _s * 0.005)
            ..lineTo(boca.dx + _s * 0.05, boca.dy - _s * 0.005)
            ..arcToPoint(
              Offset(boca.dx - _s * 0.05, boca.dy - _s * 0.005),
              radius: Radius.circular(_s * 0.05),
            );
          canvas.drawPath(sorriso, Paint()..color = const Color(0xFF5A1E1E));
        } else {
          _olho(canvas, oE, 0.3, contorno);
          _olho(canvas, oD, 0.3, contorno);
          _bocaW(canvas, boca, traco, 1);
        }
    }
  }

  /// Boca de gato em "w"; [sorriso] curva as pontas para cima.
  void _bocaW(Canvas canvas, Offset b, Paint traco, double sorriso) {
    final w = _s * 0.035;
    final up = _s * 0.012 * sorriso;
    final path = Path()
      ..moveTo(b.dx - w * 2, b.dy - up)
      ..quadraticBezierTo(b.dx - w, b.dy + w, b.dx, b.dy - _s * 0.01)
      ..quadraticBezierTo(b.dx + w, b.dy + w, b.dx + w * 2, b.dy - up);
    canvas.drawPath(path, traco);
  }

  void _extras(Canvas canvas, double arco) {
    switch (estado) {
      case EstadoAvatar.procrastinador:
        _celular(canvas, _p(0.3, 0.8));
        _texto(
          canvas,
          'z',
          _p(0.8, 0.2 - 0.05 * arco),
          _s * (0.07 + 0.03 * arco),
        );
        _texto(
          canvas,
          'Z',
          _p(0.88, 0.1 - 0.06 * arco),
          _s * (0.09 + 0.04 * arco),
        );
      case EstadoAvatar.piorando:
        _celular(canvas, _p(0.3, 0.8));
        _rabisco(canvas, _p(0.84, 0.16));
        if (reagindo) {
          _texto(canvas, '!', _p(0.16, 0.14), _s * 0.16 * math.min(1, t * 4));
        }
      case EstadoAvatar.neutro:
        _celular(canvas, _p(0.3, 0.8));
        // Patinha acenando durante a reação.
        if (reagindo) {
          final giro = math.sin(t * math.pi * 4) * 0.4;
          canvas.save();
          canvas.translate(_s * 0.8, _s * 0.78);
          canvas.rotate(-0.4 + giro);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(-_s * 0.04, -_s * 0.22, _s * 0.08, _s * 0.22),
              Radius.circular(_s * 0.04),
            ),
            Paint()..color = _moletom,
          );
          canvas.drawCircle(
            Offset(0, -_s * 0.24),
            _s * 0.05,
            Paint()..color = _pelo,
          );
          canvas.restore();
        }
      case EstadoAvatar.indoBem:
        _brilho(canvas, _p(0.84, 0.2), _s * (0.04 + 0.03 * arco));
      case EstadoAvatar.disciplinado:
        _estrela(canvas, _p(0.84, 0.18), _s * (0.05 + 0.02 * arco));
        _brilho(canvas, _p(0.14, 0.28), _s * 0.03);
    }
  }

  void _celular(Canvas canvas, Offset c) {
    final corpo = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: _s * 0.09, height: _s * 0.15),
      Radius.circular(_s * 0.015),
    );
    canvas.drawRRect(corpo, Paint()..color = const Color(0xFF0E0E12));
    canvas.drawRRect(
      corpo.deflate(_s * 0.01),
      Paint()..color = const Color(0xFF7FD3FF).withValues(alpha: 0.85),
    );
    // Patinha segurando.
    canvas.drawCircle(
      c + Offset(0, _s * 0.06),
      _s * 0.045,
      Paint()..color = _pelo,
    );
  }

  void _gatinhoEstampa(Canvas canvas, Offset c, double r) {
    final p = Paint()..color = _peloClaro.withValues(alpha: 0.8);
    canvas.drawCircle(c, r, p);
    canvas.drawPath(
      Path()..addPolygon([
        c + Offset(-r, -r * 0.3),
        c + Offset(-r * 0.8, -r * 1.6),
        c + Offset(-r * 0.1, -r * 0.9),
      ], true),
      p,
    );
    canvas.drawPath(
      Path()..addPolygon([
        c + Offset(r, -r * 0.3),
        c + Offset(r * 0.8, -r * 1.6),
        c + Offset(r * 0.1, -r * 0.9),
      ], true),
      p,
    );
  }

  void _rabisco(Canvas canvas, Offset c) {
    final p = Paint()
      ..color = TaskyColors.superficieClara
      ..style = PaintingStyle.stroke
      ..strokeWidth = _s * 0.01;
    final path = Path();
    for (var i = 0; i <= 40; i++) {
      final a = i * 0.6;
      final r = _s * (0.02 + 0.0012 * i);
      final pt = c + Offset(math.cos(a) * r, math.sin(a) * r * 0.7);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(path, p);
  }

  void _brilho(Canvas canvas, Offset c, double r) {
    final p = Paint()
      ..color = TaskyColors.superficieClara
      ..strokeWidth = _s * 0.012
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c - Offset(r, 0), c + Offset(r, 0), p);
    canvas.drawLine(c - Offset(0, r), c + Offset(0, r), p);
  }

  void _particulas(Canvas canvas) {
    const cores = [
      TaskyColors.amarelo,
      TaskyColors.verde,
      TaskyColors.dourado,
      TaskyColors.roxoClaro,
    ];
    final c = _p(0.5, 0.5);
    final opacidade = (1 - t).clamp(0.0, 1.0);
    for (var i = 0; i < 12; i++) {
      final ang = i * math.pi * 2 / 12;
      final d = _s * (0.3 + 0.4 * t);
      canvas.drawRect(
        Rect.fromCenter(
          center: c + Offset(math.cos(ang), math.sin(ang)) * d,
          width: _s * 0.04,
          height: _s * 0.04,
        ),
        Paint()..color = cores[i % cores.length].withValues(alpha: opacidade),
      );
    }
  }

  void _estrela(Canvas canvas, Offset c, double r) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final raio = i.isEven ? r : r * 0.45;
      final ang = -math.pi / 2 + i * math.pi / 5;
      final p = c + Offset(math.cos(ang), math.sin(ang)) * raio;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path..close(), Paint()..color = TaskyColors.amarelo);
  }

  void _texto(Canvas canvas, String texto, Offset centro, double tamanho) {
    if (tamanho < 1) return;
    final tp = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(
          fontFamily: kFontePixel,
          fontSize: tamanho,
          color: TaskyColors.superficieClara,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, centro - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(PintorGatoProvisorio old) =>
      old.estado != estado ||
      old.t != t ||
      old.reagindo != reagindo ||
      old.pose != pose;
}

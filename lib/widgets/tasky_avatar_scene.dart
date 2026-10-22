import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

import '../models/estado_avatar.dart';
import '../theme/tasky_theme.dart';
import 'gato_provisorio.dart';

/// Cena animada do mascote Tasky.
///
/// Com `assets/mascote/tasky_scene.riv` presente, usa o Rive (pacote
/// `rive` 0.14) pela API atual de Data Binding: o ViewModel padrão do
/// artboard deve ter a propriedade numérica `mood` (0 a 4) e o gatilho
/// `tap`, ligados à máquina de estados `TaskyStateMachine`. Quem anima
/// cabeça, olhos, reações e o retorno ao loop é o próprio arquivo.
///
/// Sem o arquivo, mostra uma PRÉVIA TEMPORÁRIA desenhada em Flutter, com
/// cabeça e corpo em camadas separadas.
///
/// Trocar o [mood] só atualiza a propriedade; o arquivo não é recarregado
/// e a tela não reinicia. Só a área do mascote recebe toques.
class TaskyAvatarScene extends StatefulWidget {
  const TaskyAvatarScene({
    super.key,
    required this.mood,
    this.tamanho = 200,
    this.arquivo = arquivoPadrao,
  });

  static const arquivoPadrao = 'assets/mascote/tasky_scene.riv';
  static const maquinaDeEstados = 'TaskyStateMachine';
  static const propriedadeMood = 'mood';
  static const gatilhoTap = 'tap';

  /// Estado do mascote, de 0 (O Procrastinador) a 4 (Disciplinado).
  final int mood;
  final double tamanho;
  final String arquivo;

  @override
  State<TaskyAvatarScene> createState() => _TaskyAvatarSceneState();
}

class _TaskyAvatarSceneState extends State<TaskyAvatarScene>
    with SingleTickerProviderStateMixin {
  /// null enquanto verifica se o .riv existe no pacote do app.
  bool? _temArquivo;
  rive.FileLoader? _loader;
  rive.ViewModelInstanceNumber? _mood;
  rive.ViewModelInstanceTrigger? _tap;
  final _previa = GlobalKey<_PreviaTemporariaState>();

  /// Pulso em Flutter: sempre visível ao tocar, mesmo que o Rive não reaja.
  late final _pulso = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void initState() {
    super.initState();
    _verificarArquivo();
  }

  Future<void> _verificarArquivo() async {
    var existe = false;
    try {
      final manifesto = await AssetManifest.loadFromAssetBundle(rootBundle);
      existe = manifesto.listAssets().contains(widget.arquivo);
    } catch (_) {
      existe = false;
    }
    rive.FileLoader? loader;
    if (existe) {
      // Tenta decodificar antes de montar o widget do Rive. Em flutter
      // test o runtime nativo não está disponível e a decodificação
      // dispara um assert; `runZonedGuarded` evita que o erro escape e
      // caímos de volta na prévia provisória.
      final concluido = Completer<bool>();
      runZonedGuarded(
        () async {
          try {
            loader = rive.FileLoader.fromAsset(
              widget.arquivo,
              riveFactory: rive.Factory.rive,
            );
            await loader!.file();
            if (!concluido.isCompleted) concluido.complete(true);
          } catch (_) {
            if (!concluido.isCompleted) concluido.complete(false);
          }
        },
        (_, _) {
          if (!concluido.isCompleted) concluido.complete(false);
        },
      );
      final ok = await concluido.future;
      if (!ok) {
        loader?.dispose();
        loader = null;
        existe = false;
      }
    }
    if (!mounted) {
      loader?.dispose();
      return;
    }
    setState(() {
      _temArquivo = existe;
      _loader = loader;
    });
  }

  @override
  void didUpdateWidget(TaskyAvatarScene old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) _mood?.value = widget.mood.toDouble();
  }

  @override
  void dispose() {
    _pulso.dispose();
    _loader?.dispose();
    super.dispose();
  }

  void _aoCarregar(rive.RiveLoaded estado) {
    final vm = estado.viewModelInstance;
    _mood = vm?.number(TaskyAvatarScene.propriedadeMood);
    _tap = vm?.trigger(TaskyAvatarScene.gatilhoTap);
    _mood?.value = widget.mood.toDouble();
    if (_mood == null || _tap == null) {
      debugPrint(
        'tasky_scene.riv: ViewModel sem "${TaskyAvatarScene.propriedadeMood}" '
        'ou "${TaskyAvatarScene.gatilhoTap}". Confira o Data Binding.',
      );
    }
  }

  void _tocar() {
    if (!_pulso.isAnimating) _pulso.forward(from: 0);
    final tap = _tap;
    if (tap != null) tap.trigger();
    _previa.currentState?.tocar();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.tamanho;
    final previa = _PreviaTemporaria(
      key: _previa,
      mood: widget.mood,
      tamanho: s,
    );

    final Widget conteudo = switch (_temArquivo) {
      null => SizedBox.square(dimension: s),
      false => previa,
      true => SizedBox.square(
        dimension: s,
        child: rive.RiveWidgetBuilder(
          fileLoader: _loader!,
          stateMachineSelector: rive.StateMachineSelector.byName(
            TaskyAvatarScene.maquinaDeEstados,
          ),
          dataBind: rive.DataBind.auto(),
          onLoaded: _aoCarregar,
          builder: (context, estado) => switch (estado) {
            rive.RiveLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            // Arquivo inválido ou incompatível: volta para a prévia.
            rive.RiveFailed() => previa,
            rive.RiveLoaded() => rive.RiveWidget(
              controller: estado.controller,
              fit: rive.Fit.contain,
              // O toque é tratado pelo GestureDetector abaixo, só na
              // área do mascote.
              hitTestBehavior: rive.RiveHitTestBehavior.none,
            ),
          },
        ),
      ),
    };

    return GestureDetector(
      onTap: _tocar,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _pulso,
        builder: (context, filho) {
          // Pulso visível sempre, para o toque não parecer sem resposta.
          final v = math.sin(math.pi * _pulso.value);
          return Transform.scale(scale: 1 + 0.06 * v, child: filho);
        },
        child: conteudo,
      ),
    );
  }
}

/// PRÉVIA TEMPORÁRIA: substituir pelo tasky_scene.riv.
///
/// Loop contínuo (respiração, olhar para o celular, piscadas). No toque:
/// a cabeça gira para a frente e os olhos encaram quem usa o celular, a
/// reação do estado toca e tudo volta ao loop. Só a camada da cabeça se
/// move; o corpo fica no lugar (exceto no salto dos estados 4 e 5).
class _PreviaTemporaria extends StatefulWidget {
  const _PreviaTemporaria({
    super.key,
    required this.mood,
    required this.tamanho,
  });

  final int mood;
  final double tamanho;

  @override
  State<_PreviaTemporaria> createState() => _PreviaTemporariaState();
}

class _PreviaTemporariaState extends State<_PreviaTemporaria>
    with TickerProviderStateMixin {
  late final _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );
  late final _toque = AnimationController(vsync: this);

  /// Estado em que o toque começou, para não trocar no meio da reação.
  EstadoAvatar? _estadoToque;
  bool _semMovimento = false;

  EstadoAvatar get _estado =>
      EstadoAvatar.values[widget.mood.clamp(0, EstadoAvatar.values.length - 1)];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _semMovimento = MediaQuery.disableAnimationsOf(context);
    if (_semMovimento) {
      _loop.stop();
      _loop.value = 0;
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _toque.dispose();
    super.dispose();
  }

  /// Toques durante a reação são ignorados.
  void tocar() {
    if (_toque.isAnimating) return;
    _estadoToque = _estado;
    _toque.duration = _estado == EstadoAvatar.disciplinado
        ? const Duration(milliseconds: 1800)
        : const Duration(milliseconds: 1500);
    _toque.forward(from: 0).whenComplete(() => _estadoToque = null);
  }

  /// Para onde o gato olha no loop: o celular (1–3), o notebook (4) ou
  /// o alto, relaxado (5).
  static Offset _olharDoLoop(EstadoAvatar e) => switch (e) {
    EstadoAvatar.procrastinador ||
    EstadoAvatar.piorando ||
    EstadoAvatar.neutro => const Offset(-0.7, 0.6),
    EstadoAvatar.indoBem => const Offset(0.6, 0.3),
    EstadoAvatar.disciplinado => const Offset(0.4, -0.4),
  };

  @override
  Widget build(BuildContext context) {
    final s = widget.tamanho;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_loop, _toque]),
          builder: (context, _) {
            final e = _toque.isAnimating ? (_estadoToque ?? _estado) : _estado;
            final l = _loop.value;
            final ondaLoop = math.sin(2 * math.pi * l);
            final piscandoNoLoop =
                (l > 0.46 && l < 0.5) || (l > 0.9 && l < 0.93);

            // Toque: 0–20% vira para a frente, 20–85% reação, 85–100% volta.
            final tt = _toque.isAnimating ? _toque.value : 0.0;
            final frente = Curves.easeInOut.transform(
              tt < 0.2
                  ? tt / 0.2
                  : tt < 0.85
                  ? 1
                  : (1 - tt) / 0.15,
            );
            final reagindo = tt > 0.2 && tt < 0.85;
            final r = reagindo ? (tt - 0.2) / 0.65 : 0.0;
            final arco = math.sin(math.pi * r);

            double lerp(double a, double b) => a + (b - a) * frente;
            final mov = _semMovimento ? 0.0 : 1.0;

            final pose = (
              giro: lerp(-0.1 + 0.03 * ondaLoop * mov, 0),
              dx: lerp(-0.03, 0),
              dy:
                  -0.006 * ondaLoop * mov -
                  (e == EstadoAvatar.piorando ? 0.025 * arco * mov : 0),
              olhar: Offset.lerp(_olharDoLoop(e), Offset.zero, frente)!,
              piscar: !reagindo && frente < 0.5 && piscandoNoLoop,
              encarando:
                  frente > 0.5 && !reagindo ||
                  (reagindo && e != EstadoAvatar.procrastinador),
            );

            // Salto de corpo inteiro só nos estados 4 e 5 (é um salto,
            // não um giro de cabeça).
            final salto = switch (e) {
              EstadoAvatar.indoBem => 0.08,
              EstadoAvatar.disciplinado => 0.16,
              _ => 0.0,
            };

            return Transform.translate(
              offset: Offset(0, -arco * s * salto * mov),
              child: SizedBox.square(
                dimension: s,
                child: CustomPaint(
                  painter: PintorGatoProvisorio(
                    estado: e,
                    t: r,
                    reagindo: reagindo,
                    pose: pose,
                  ),
                ),
              ),
            );
          },
        ),
        const Positioned(left: 0, top: 0, child: _SeloTemporario()),
      ],
    );
  }
}

class _SeloTemporario extends StatelessWidget {
  const _SeloTemporario();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: TaskyColors.fundo.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TaskyColors.amarelo),
      ),
      child: const Text(
        'PRÉVIA TEMPORÁRIA',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: TaskyColors.amarelo,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'tasky_avatar_scene.dart';

/// Com `false`, o mascote é o rig `rive/tasky_v2` em resolução cheia:
/// respira, pisca, mexe as orelhas e balança a cauda.
///
/// Pôr `true` volta para a arte parada de `assets/avatar/`, uma imagem
/// por mood. A troca não é neutra: o rig tem só as peças do corpo base
/// (mood 2), então nele o humor aparece na POSTURA, enquanto na arte
/// parada cada mood tem corpo e rosto próprios. Os semblantes por mood
/// são o item 1 de "O QUE FALTA CRIAR", em arte/MOVIMENTOS.md.
const bool mascoteParado = false;

/// Diorama do Tasky: o quarto do mood ao fundo e o mascote em pé no
/// tapete.
///
/// Os cinco quartos são assets do Flutter, não peças do `.riv`. Nada
/// neles se mexe, e cinco imagens de 1536x1024 dentro do arquivo Rive
/// fariam cada ajuste de arte depender de um rebuild do rig.
///
/// A troca de quarto é um cross-fade quando a tela está à vista
/// ([visivel]) e instantânea quando não está: subir de nível com o app
/// em outra aba não deve gastar a animação no vazio.
class CenarioTasky extends StatefulWidget {
  const CenarioTasky({
    super.key,
    required this.mood,
    this.visivel = true,
    this.alturaMascote = alturaMascotePadrao,
    this.linhaDoChao = linhaDoChaoPadrao,
  });

  /// Proporção dos quartos (1536x1024).
  static const proporcao = 1536 / 1024;

  /// Duração do cross-fade entre dois quartos.
  static const duracaoTroca = Duration(milliseconds: 700);

  /// Altura da caixa do mascote, em fração da altura do quarto.
  /// Serve para os dois caminhos: o artboard do rig v2 é a mesma moldura
  /// 1024x1536 em que a arte parada foi desenhada, então o `Fit.contain`
  /// enquadra os dois igual e o valor não muda ao trocar a chave.
  static const alturaMascotePadrao = 0.77;

  /// Onde ficam os pés, em fração da altura do quarto.
  /// 0.86 cai na metade da frente do tapete, que está alinhado nos
  /// cinco quartos (base medida entre 979 e 983 de 1024).
  static const linhaDoChaoPadrao = 0.86;

  /// Estado do mascote, de 0 (O Procrastinador) a 4 (Disciplinado).
  final int mood;

  /// Se a aba do avatar é a que está em primeiro plano. Com `false`,
  /// a troca de quarto é instantânea.
  final bool visivel;

  final double alturaMascote;
  final double linhaDoChao;

  /// Quarto que cada mood usa, por índice de mood.
  ///
  /// O mood 2 reaproveita o quarto do mood 1 de propósito: subir de
  /// Piorando para Neutro não muda o cenário, só o humor do mascote.
  /// Por isso não existe `mood2.webp` — o arquivo original continua em
  /// `arte/cenario/`, fora do app.
  static const _quartoDoMood = [0, 1, 1, 3, 4];

  /// Índice do quarto usado por um mood.
  static int quartoDoMood(int mood) => _quartoDoMood[mood.clamp(0, 4)];

  /// Caminho do quarto de um mood.
  static String arquivoDoQuarto(int mood) =>
      arquivoDoIndice(quartoDoMood(mood));

  /// Caminho de um quarto pelo índice dele.
  static String arquivoDoIndice(int quarto) =>
      'assets/cenario/mood$quarto.webp';

  /// Arte parada do mascote, uma por mood: o caminho de `mascoteParado`.
  static String arquivoDoAvatar(int mood) =>
      'assets/avatar/mood${mood.clamp(0, 4)}.webp';

  @override
  State<CenarioTasky> createState() => _CenarioTaskyState();
}

class _CenarioTaskyState extends State<CenarioTasky>
    with SingleTickerProviderStateMixin {
  late int _quartoAtual = CenarioTasky.quartoDoMood(widget.mood);

  /// Quarto que está saindo. Fica embaixo, opaco, enquanto o novo
  /// aparece por cima: assim o cross-fade não passa por um vão escuro,
  /// como aconteceria se os dois trocassem de opacidade ao mesmo tempo.
  int? _quartoAnterior;

  late final _fade = AnimationController(
    vsync: this,
    duration: CenarioTasky.duracaoTroca,
    value: 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prepararProximo();
  }

  /// Deixa pronto só o quarto seguinte. Precarregar os cinco custaria
  /// cerca de 30 MB de bitmap decodificado, o que não se justifica para
  /// uma troca que acontece poucas vezes.
  void _prepararProximo() {
    if (widget.mood >= 4) return;
    final proximo = CenarioTasky.quartoDoMood(widget.mood + 1);
    if (proximo == _quartoAtual) return;
    precacheImage(
      AssetImage(CenarioTasky.arquivoDoIndice(proximo)),
      context,
    ).ignore();
  }

  @override
  void didUpdateWidget(CenarioTasky old) {
    super.didUpdateWidget(old);
    if (old.mood == widget.mood) return;

    // Moods que dividem o mesmo quarto (1 e 2) não trocam nada: só o
    // mascote muda de humor.
    final novo = CenarioTasky.quartoDoMood(widget.mood);
    if (novo == _quartoAtual) return;

    if (widget.visivel) {
      setState(() {
        _quartoAnterior = _quartoAtual;
        _quartoAtual = novo;
      });
      _fade.forward(from: 0).whenComplete(() {
        if (mounted) setState(() => _quartoAnterior = null);
      });
    } else {
      // Ninguém viu: já entra atualizado.
      setState(() {
        _quartoAnterior = null;
        _quartoAtual = novo;
      });
      _fade.value = 1;
    }
    _prepararProximo();
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  Widget _quarto(int quarto) => Image.asset(
    CenarioTasky.arquivoDoIndice(quarto),
    fit: BoxFit.cover,
    filterQuality: FilterQuality.medium,
    gaplessPlayback: true,
    excludeFromSemantics: true,
  );

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: CenarioTasky.proporcao,
      child: LayoutBuilder(
        builder: (context, limites) {
          final altura = limites.maxHeight;
          final lado = altura * widget.alturaMascote;
          return Stack(
            fit: StackFit.expand,
            children: [
              if (_quartoAnterior != null) _quarto(_quartoAnterior!),
              FadeTransition(opacity: _fade, child: _quarto(_quartoAtual)),
              Positioned(
                left: 0,
                right: 0,
                top: altura * widget.linhaDoChao - lado,
                height: lado,
                child: Center(
                  child: TaskyAvatarScene(
                    mood: widget.mood,
                    tamanho: lado,
                    imagemParada: mascoteParado
                        ? CenarioTasky.arquivoDoAvatar(widget.mood)
                        : null,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

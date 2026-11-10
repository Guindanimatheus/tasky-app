import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/estado_avatar.dart';
import 'package:flutter_application_1/widgets/avatar_tasky.dart';
import 'package:flutter_application_1/widgets/cenario_tasky.dart';
import 'package:flutter_application_1/widgets/tasky_avatar_scene.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('faixas de XP são crescentes e cobrem os limites', () {
    final minimos = EstadoAvatar.values.map((e) => e.xpMinimo).toList();
    expect(minimos.first, 0);
    for (var i = 1; i < minimos.length; i++) {
      expect(minimos[i], greaterThan(minimos[i - 1]));
    }
    for (final e in EstadoAvatar.values) {
      expect(EstadoAvatar.paraXp(e.xpMinimo), e);
      if (e.xpMinimo > 0) {
        expect(EstadoAvatar.paraXp(e.xpMinimo - 1).index, e.index - 1);
      }
    }
    expect(EstadoAvatar.paraXp(-10), EstadoAvatar.procrastinador);
    expect(EstadoAvatar.paraXp(99999), EstadoAvatar.disciplinado);
    expect(EstadoAvatar.disciplinado.progresso(99999), 1);
  });

  for (final e in EstadoAvatar.values) {
    testWidgets('estado ${e.numero} reage e ignora toques repetidos', (
      tester,
    ) async {
      _semAnimacoesContinuas(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: AvatarTasky(xp: e.xpMinimo)),
          ),
        ),
      );
      expect(find.text(e.nome.toUpperCase()), findsOneWidget);
      expect(find.text('“${e.frase}”'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Estado ${e.numero} de 5')),
        findsOneWidget,
      );

      final avatar = find.byType(GestureDetector).first;
      for (var i = 0; i < 5; i++) {
        await tester.tap(avatar);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('sem o .riv mostra a prévia temporária identificada', (
    tester,
  ) async {
    _semAnimacoesContinuas(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: TaskyAvatarScene(
            mood: 2,
            arquivo: 'assets/mascote/nao_existe.riv',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('PRÉVIA TEMPORÁRIA'), findsOneWidget);
  });

  testWidgets('trocar o mood não recria a cena', (tester) async {
    _semAnimacoesContinuas(tester);
    Widget cena(int mood) => MaterialApp(
      home: Center(child: TaskyAvatarScene(mood: mood)),
    );
    await tester.pumpWidget(cena(0));
    await tester.pumpAndSettle();
    final antes = tester.state(find.byType(TaskyAvatarScene));
    await tester.pumpWidget(cena(4));
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(TaskyAvatarScene)), same(antes));
  });

  group('troca de quarto', () {
    Finder quarto(int mood) => find.byWidgetPredicate(
      (w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName ==
              CenarioTasky.arquivoDoQuarto(mood),
    );

    Widget diorama(int mood, {required bool visivel}) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: CenarioTasky(mood: mood, visivel: visivel),
        ),
      ),
    );

    // Sem _semAnimacoesContinuas: o AnimationController obedece ao
    // "reduzir animações" do sistema e pularia o cross-fade inteiro —
    // que é justamente o que o terceiro caso verifica.
    testWidgets('à vista, o quarto antigo continua sob o novo durante '
        'o cross-fade', (tester) async {
      await tester.pumpWidget(diorama(0, visivel: true));
      await tester.pump();
      expect(quarto(0), findsOneWidget);

      await tester.pumpWidget(diorama(1, visivel: true));
      await tester.pump(const Duration(milliseconds: 100));
      // Os dois juntos: é isso que evita o vão escuro no meio da troca.
      expect(quarto(0), findsOneWidget);
      expect(quarto(1), findsOneWidget);

      await tester.pump(CenarioTasky.duracaoTroca);
      await tester.pump();
      expect(quarto(0), findsNothing);
      expect(quarto(1), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('moods 1 e 2 dividem o quarto: subir de 1 para 2 não '
        'troca o cenário', (tester) async {
      expect(CenarioTasky.arquivoDoQuarto(2), CenarioTasky.arquivoDoQuarto(1));

      await tester.pumpWidget(diorama(1, visivel: true));
      await tester.pump();

      await tester.pumpWidget(diorama(2, visivel: true));
      await tester.pump(const Duration(milliseconds: 100));
      // Um quarto só na árvore: nada de cross-fade da imagem com ela
      // mesma. (O mascote também é um Image, por isso o filtro.)
      final quartos = find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName.startsWith('assets/cenario/'),
      );
      expect(quartos, findsOneWidget);
      expect(quarto(1), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('fora de vista, o quarto já entra trocado', (tester) async {
      await tester.pumpWidget(diorama(2, visivel: false));
      await tester.pump();

      await tester.pumpWidget(diorama(3, visivel: false));
      await tester.pump();
      // Sem animação: nada de quarto antigo pendurado na árvore.
      expect(quarto(2), findsNothing);
      expect(quarto(3), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('com "reduzir animações" a troca é seca', (tester) async {
      _semAnimacoesContinuas(tester);
      await tester.pumpWidget(diorama(2, visivel: true));
      await tester.pump();

      await tester.pumpWidget(diorama(3, visivel: true));
      await tester.pump(const Duration(milliseconds: 100));
      expect(quarto(2), findsNothing);
      expect(quarto(3), findsOneWidget);
    });
  });
}

/// A cena do mascote fica em loop; com "reduzir animações" ligado ela para,
/// e o pumpAndSettle consegue terminar.
void _semAnimacoesContinuas(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

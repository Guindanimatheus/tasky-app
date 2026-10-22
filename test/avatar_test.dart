import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/estado_avatar.dart';
import 'package:flutter_application_1/widgets/avatar_tasky.dart';
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
}

/// A cena do mascote fica em loop; com "reduzir animações" ligado ela para,
/// e o pumpAndSettle consegue terminar.
void _semAnimacoesContinuas(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

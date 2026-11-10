import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/providers/tasky_controller.dart';
import 'package:flutter_application_1/services/armazenamento.dart';
import 'package:flutter_application_1/services/conta_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<TaskyApp> _app({bool logado = true, bool splash = false}) async {
  SharedPreferences.setMockInitialValues({});
  final armazenamento = await Armazenamento.abrir();
  final conta = await ContaLocal.abrir();
  if (logado) await conta.cadastrar('ana@email.com', 'segredo1');
  return TaskyApp(
    controller: TaskyController(armazenamento),
    conta: conta,
    mostrarSplash: splash,
  );
}

void main() {
  testWidgets('navegação inferior alterna entre as abas', (tester) async {
    _semAnimacoesContinuas(tester);
    await tester.pumpWidget(await _app());

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('O PROCRASTINADOR'), findsOneWidget);

    await tester.tap(find.text('Trilhas').last);
    await tester.pumpAndSettle();
    expect(find.text('O Primeiro Passo'), findsOneWidget);

    await tester.tap(find.text('Tarefas').last);
    await tester.pumpAndSettle();
    expect(find.text('Sem tarefas'), findsOneWidget);
  });

  testWidgets('layout cabe em celular pequeno sem overflow', (tester) async {
    _semAnimacoesContinuas(tester);
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('título em branco não cria tarefa', (tester) async {
    _semAnimacoesContinuas(tester);
    await tester.pumpWidget(await _app());
    await tester.tap(find.text('Tarefas').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Nova tarefa'));
    await tester.pumpAndSettle();
    // Deixa o título em branco e tenta salvar.
    final botaoAdicionar = find.widgetWithText(FilledButton, 'Adicionar');
    await tester.ensureVisible(botaoAdicionar);
    await tester.tap(botaoAdicionar);
    await tester.pumpAndSettle();
    expect(find.text('Escreva um título para a tarefa.'), findsOneWidget);

    // Agora com título válido.
    await tester.enterText(find.byType(TextFormField).first, 'Beber água');
    await tester.ensureVisible(botaoAdicionar);
    await tester.tap(botaoAdicionar);
    await tester.pumpAndSettle();
    expect(find.text('Beber água'), findsOneWidget);
    expect(find.text('Sem tarefas'), findsNothing);
  });

  testWidgets('excluir mostra SnackBar com desfazer', (tester) async {
    _semAnimacoesContinuas(tester);
    await tester.pumpWidget(await _app());
    await tester.tap(find.text('Tarefas').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Nova tarefa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Ler');
    final botaoAdicionar = find.widgetWithText(FilledButton, 'Adicionar');
    await tester.ensureVisible(botaoAdicionar);
    await tester.tap(botaoAdicionar);
    await tester.pumpAndSettle();
    expect(find.text('Ler'), findsOneWidget);

    // Excluir pelo menu de opções.
    await tester.tap(find.byTooltip('Opções'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('"Ler" foi excluída.'), findsOneWidget);
    expect(find.text('Ler'), findsNothing);

    // Desfazer traz a tarefa de volta. O SnackBar fica num Overlay fora
    // da hit area normal do teste; chamo a ação direto para contornar.
    final acao = tester.widget<SnackBarAction>(
      find.widgetWithText(SnackBarAction, 'Desfazer'),
    );
    acao.onPressed();
    await tester.pumpAndSettle();
    expect(find.text('Ler'), findsOneWidget);
  });

  testWidgets('splash leva ao cadastro, que valida e entra no app', (
    tester,
  ) async {
    _semAnimacoesContinuas(tester);
    await tester.pumpWidget(await _app(logado: false, splash: true));
    expect(find.text('Transforme tarefas em conquistas.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo ao Tasky!'), findsOneWidget);
    expect(find.text('CADASTRAR'), findsOneWidget);

    await tester.ensureVisible(find.text('CADASTRAR'));
    await tester.tap(find.text('CADASTRAR'));
    await tester.pumpAndSettle();
    expect(find.text('Informe seu e-mail.'), findsOneWidget);

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'ana@email.com');
    await tester.enterText(campos.at(1), 'segredo1');
    await tester.enterText(campos.at(2), 'outra123');
    await tester.ensureVisible(find.text('CADASTRAR'));
    await tester.tap(find.text('CADASTRAR'));
    await tester.pumpAndSettle();
    expect(find.text('As senhas não são iguais.'), findsOneWidget);

    await tester.enterText(campos.at(2), 'segredo1');
    await tester.ensureVisible(find.text('CADASTRAR'));
    await tester.tap(find.text('CADASTRAR'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}

/// A cena do mascote fica em loop; com "reduzir animações" ligado ela para,
/// e o pumpAndSettle consegue terminar.
void _semAnimacoesContinuas(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

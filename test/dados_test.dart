import 'package:flutter_application_1/data/trilhas_padrao.dart';
import 'package:flutter_application_1/models/regras_xp.dart';
import 'package:flutter_application_1/models/tarefa.dart';
import 'package:flutter_application_1/models/trilha.dart';
import 'package:flutter_application_1/providers/tasky_controller.dart';
import 'package:flutter_application_1/services/armazenamento.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<TaskyController> _controller([
  Map<String, Object> iniciais = const {},
]) async {
  SharedPreferences.setMockInitialValues(iniciais);
  return TaskyController(await Armazenamento.abrir());
}

void main() {
  test('concluir concede XP uma única vez', () async {
    final c = await _controller();
    final t = await c.adicionarTarefa(titulo: 'Ler', xp: 20);

    await c.alternarConclusao(t.id);
    expect(c.progresso.xp, 20);

    await c.alternarConclusao(t.id); // reabre: não perde XP
    expect(c.progresso.xp, 20);
    expect(c.tarefas.single.concluida, isFalse);

    await c.alternarConclusao(t.id); // conclui de novo: não duplica
    expect(c.progresso.xp, 20);
  });

  test('atraso tira XP conforme a dificuldade, uma única vez', () async {
    final hoje = DateTime(2026, 10, 21);
    final antiga = DateTime(2026, 10, 18); // 3 dias de atraso
    SharedPreferences.setMockInitialValues({'tasky.xp': 100});
    final c = TaskyController(await Armazenamento.abrir(), relogio: () => hoje);
    // Sem trilha (leve): não perde.
    await c.adicionarTarefa(titulo: 'Leve', data: antiga);
    expect(await c.verificarAtrasos(), 0);
    expect(c.progresso.xp, 100);

    // Trilha difícil: perde 100% do que a tarefa daria.
    await c.selecionarTrilha(
      trilhaPorId('disciplina-na-pratica')!,
      adicionarTarefas: false,
    );
    await c.adicionarTarefa(titulo: 'Hard', data: antiga, xp: 15);
    expect(await c.verificarAtrasos(), 15);
    expect(c.progresso.xp, 85);
    expect(await c.verificarAtrasos(), 0); // não pune de novo

    // Tarefa com só 1 dia de atraso ainda não perde.
    await c.adicionarTarefa(titulo: 'Ontem', data: DateTime(2026, 10, 20));
    expect(await c.verificarAtrasos(), 0);
  });

  test('XP fica entre 0 e o máximo', () async {
    final c = await _controller({'tasky.xp': RegrasXp.xpMaximo + 50});
    expect(c.progresso.xp, RegrasXp.xpMaximo);
    expect(c.progresso.perder(5000).xp, 0);
  });

  test('combo de 5 dias seguidos dá bônus uma vez', () async {
    var dia = DateTime(2026, 10, 1);
    SharedPreferences.setMockInitialValues({});
    final c = TaskyController(await Armazenamento.abrir(), relogio: () => dia);
    var bonus = 0;
    for (var i = 0; i < RegrasXp.diasCombo; i++) {
      final t = await c.adicionarTarefa(titulo: 'Dia $i');
      bonus = await c.alternarConclusao(t.id);
      if (i < RegrasXp.diasCombo - 1) {
        expect(bonus, 0);
        dia = dia.add(const Duration(days: 1));
      }
    }
    expect(bonus, RegrasXp.bonusCombo);
    expect(c.sequenciaDias, RegrasXp.diasCombo);
    expect(
      c.progresso.xp,
      RegrasXp.diasCombo * RegrasXp.xpTarefaPropria + RegrasXp.bonusCombo,
    );
    // Outra tarefa no mesmo dia não repete o bônus.
    final extra = await c.adicionarTarefa(titulo: 'Extra');
    expect(await c.alternarConclusao(extra.id), 0);
  });

  test('dados persistem entre aberturas', () async {
    final c = await _controller();
    final t = await c.adicionarTarefa(
      titulo: 'Treinar',
      observacao: '30 min',
      categoria: 'Saúde',
      data: DateTime(2026, 10, 25),
    );
    await c.alternarConclusao(t.id);
    await c.selecionarTrilha(
      const Trilha(
        id: 'foco',
        nome: 'Foco',
        descricao: '',
        tarefas: [TarefaModelo(titulo: 'Meditar')],
      ),
    );

    final reaberto = TaskyController(await Armazenamento.abrir());
    expect(reaberto.progresso.xp, 10);
    expect(reaberto.trilhaId, 'foco');
    expect(reaberto.tarefas, hasLength(2));
    final salvo = reaberto.tarefas.first;
    expect(salvo.observacao, '30 min');
    expect(salvo.data, DateTime(2026, 10, 25));
    expect(salvo.xpConcedido, isTrue);
    expect(reaberto.tarefas.last.veioDeTrilha, isTrue);
  });

  test('dados inválidos ou ausentes viram padrão', () async {
    final c = await _controller({
      'tasky.tarefas': '[{"id":"1","titulo":"ok"}, {"titulo":"sem id"}, 42]',
      'tasky.xp': -5,
      'tasky.trilha': '',
    });
    expect(c.tarefas.single.titulo, 'ok');
    expect(c.progresso.xp, 0);
    expect(c.trilhaId, isNull);

    final corrompido = await _controller({'tasky.tarefas': '{não é json'});
    expect(corrompido.tarefas, isEmpty);
  });

  test('fromJson rejeita entradas sem campos obrigatórios', () {
    expect(Tarefa.fromJson(null), isNull);
    expect(Tarefa.fromJson({'id': '', 'titulo': 'x'}), isNull);
    expect(Tarefa.fromJson({'id': 'a', 'titulo': 'x', 'xp': 'dez'})?.xp, 10);
  });

  test('trilha personalizada persiste e não apaga tarefas', () async {
    const trilha = Trilha(
      id: 't',
      nome: 'T',
      descricao: '',
      tarefas: [
        TarefaModelo(titulo: 'A'),
        TarefaModelo(titulo: 'B'),
      ],
    );
    final c = await _controller();
    await c.adicionarTarefa(titulo: 'Minha');
    await c.editarTarefaDaTrilha(trilha, 0, 'A editada');
    await c.removerTarefaDaTrilha(trilha, 1);
    await c.incluirTarefaNaTrilha(trilha, '  ');
    await c.incluirTarefaNaTrilha(trilha, 'C');

    final reaberto = TaskyController(await Armazenamento.abrir());
    expect(reaberto.tarefasDaTrilha(trilha).map((m) => m.titulo), [
      'A editada',
      'C',
    ]);
    expect(await reaberto.selecionarTrilha(trilha), 2);
    expect(await reaberto.selecionarTrilha(trilha), 0); // sem duplicar
    expect(reaberto.tarefas.map((t) => t.titulo), ['Minha', 'A editada', 'C']);

    await reaberto.restaurarTrilha(trilha);
    expect(reaberto.tarefasDaTrilha(trilha), hasLength(2));
  });

  test('escolher trilha sem adicionar tarefas', () async {
    final c = await _controller();
    final n = await c.selecionarTrilha(
      const Trilha(
        id: 'x',
        nome: 'X',
        descricao: '',
        tarefas: [TarefaModelo(titulo: 'A')],
      ),
      adicionarTarefas: false,
    );
    expect(n, 0);
    expect(c.trilhaId, 'x');
    expect(c.tarefas, isEmpty);
  });
}

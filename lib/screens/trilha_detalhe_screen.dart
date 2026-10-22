import 'package:flutter/material.dart';

import '../models/regras_xp.dart';
import '../models/trilha.dart';
import '../providers/tasky_controller.dart';
import '../widgets/dialogos.dart';
import '../widgets/estado_vazio.dart';

/// Detalhes de uma trilha: escolher e personalizar as tarefas.
class TrilhaDetalheScreen extends StatelessWidget {
  const TrilhaDetalheScreen({
    super.key,
    required this.trilha,
    required this.cor,
  });

  final Trilha trilha;
  final Color cor;

  Future<void> _escolher(BuildContext context) async {
    final controller = TaskyScope.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    final quantidade = controller.tarefasDaTrilha(trilha).length;
    final adicionar =
        quantidade > 0 &&
        await confirmar(
          context,
          titulo: 'Adicionar tarefas?',
          mensagem:
              'Quer adicionar as $quantidade tarefas desta trilha à sua '
              'lista? Suas tarefas atuais continuam onde estão.',
          rotuloConfirmar: 'Adicionar',
          rotuloCancelar: 'Agora não',
        );
    final novas = await controller.selecionarTrilha(
      trilha,
      adicionarTarefas: adicionar,
    );
    mensageiro.showSnackBar(
      SnackBar(
        content: Text(
          !adicionar
              ? 'Trilha "${trilha.nome}" escolhida.'
              : novas == 0
              ? 'Trilha escolhida. As tarefas dela já estavam na sua lista.'
              : 'Trilha escolhida. $novas tarefas adicionadas.',
        ),
      ),
    );
  }

  Future<void> _incluir(BuildContext context) async {
    final controller = TaskyScope.of(context);
    final titulo = await pedirTitulo(
      context,
      titulo: 'Nova tarefa da trilha',
      rotuloConfirmar: 'Incluir',
    );
    if (titulo != null) await controller.incluirTarefaNaTrilha(trilha, titulo);
  }

  Future<void> _editar(BuildContext context, int i, TarefaModelo m) async {
    final controller = TaskyScope.of(context);
    final titulo = await pedirTitulo(
      context,
      titulo: 'Editar tarefa',
      inicial: m.titulo,
    );
    if (titulo != null) {
      await controller.editarTarefaDaTrilha(trilha, i, titulo);
    }
  }

  Future<void> _remover(BuildContext context, int i, TarefaModelo m) async {
    final controller = TaskyScope.of(context);
    final ok = await confirmar(
      context,
      titulo: 'Remover da trilha?',
      mensagem:
          '"${m.titulo}" sairá desta trilha. '
          'Tarefas que já estão na sua lista não mudam.',
      rotuloConfirmar: 'Remover',
      destrutivo: true,
    );
    if (ok) await controller.removerTarefaDaTrilha(trilha, i);
  }

  Future<void> _restaurar(BuildContext context) async {
    final controller = TaskyScope.of(context);
    final ok = await confirmar(
      context,
      titulo: 'Restaurar trilha?',
      mensagem:
          'As tarefas desta trilha voltarão a ser as originais. '
          'Sua lista de tarefas não muda.',
      rotuloConfirmar: 'Restaurar',
    );
    if (ok) await controller.restaurarTrilha(trilha);
  }

  @override
  Widget build(BuildContext context) {
    final controller = TaskyScope.of(context);
    final tema = Theme.of(context);
    final tarefas = controller.tarefasDaTrilha(trilha);
    final selecionada = controller.trilhaId == trilha.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(trilha.nome),
        actions: [
          if (controller.trilhaPersonalizada(trilha))
            IconButton(
              tooltip: 'Restaurar tarefas originais',
              icon: const Icon(Icons.restart_alt),
              onPressed: () => _restaurar(context),
            ),
        ],
      ),
      body: ConteudoAba(
        children: [
          Text(trilha.descricao, style: tema.textTheme.bodyLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 18, color: cor),
              const SizedBox(width: 6),
              Expanded(child: Text('Duração sugerida: ${trilha.duracao}')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.speed, size: 18, color: cor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Dificuldade ${trilha.dificuldade.nome}: '
                  '+${trilha.dificuldade.xpPorTarefa} XP por tarefa. '
                  '${_textoPerda(trilha)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _escolher(context),
            icon: Icon(selecionada ? Icons.check : Icons.flag),
            label: Text(selecionada ? 'Trilha atual' : 'Escolher trilha'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text('Tarefas', style: tema.textTheme.titleLarge),
              ),
              TextButton.icon(
                onPressed: () => _incluir(context),
                icon: const Icon(Icons.add),
                label: const Text('Incluir'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (tarefas.isEmpty)
            EstadoVazio(
              icone: Icons.playlist_add,
              cor: cor,
              titulo: 'Trilha sem tarefas',
              mensagem: 'Inclua as tarefas que quiser para esta trilha.',
            )
          else
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < tarefas.length; i++)
                    ListTile(
                      leading: Icon(Icons.circle_outlined, color: cor),
                      title: Text(tarefas[i].titulo),
                      subtitle: tarefas[i].categoria == null
                          ? null
                          : Text(tarefas[i].categoria!),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _editar(context, i, tarefas[i]),
                          ),
                          IconButton(
                            tooltip: 'Remover',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _remover(context, i, tarefas[i]),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

String _textoPerda(Trilha t) {
  final perda = t.dificuldade.perdaPara(t.dificuldade.xpPorTarefa);
  return perda == 0
      ? 'Atrasos não tiram XP.'
      : 'Tarefa com ${RegrasXp.diasParaPenalizar}+ dias de atraso '
            'tira $perda XP.';
}

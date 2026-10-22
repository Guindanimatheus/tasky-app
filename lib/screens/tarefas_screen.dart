import 'package:flutter/material.dart';

import '../models/regras_xp.dart';
import '../models/tarefa.dart';
import '../providers/tasky_controller.dart';
import '../theme/tasky_theme.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/formulario_tarefa.dart';

class TarefasScreen extends StatelessWidget {
  const TarefasScreen({super.key});

  Future<void> _adicionar(BuildContext context) async {
    final controller = TaskyScope.of(context);
    final dados = await abrirFormularioTarefa(context);
    if (dados == null) return;
    await controller.adicionarTarefa(
      titulo: dados.titulo,
      observacao: dados.observacao,
      categoria: dados.categoria,
      data: dados.data,
      xp: dados.xp,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TaskyScope.of(context);
    final tema = Theme.of(context);
    final pendentes = _ordenarPendentes(controller.pendentes);
    final concluidas = controller.concluidas;
    final atrasadas = pendentes.where((t) => t.atrasada()).toList();

    return ConteudoAba(
      children: [
        FilledButton.icon(
          onPressed: () => _adicionar(context),
          icon: const Icon(Icons.add),
          label: const Text('Nova tarefa'),
        ),
        const SizedBox(height: 16),
        if (pendentes.isEmpty && concluidas.isEmpty)
          const EstadoVazio(
            icone: Icons.checklist_rounded,
            cor: TaskyColors.verde,
            titulo: 'Sem tarefas',
            mensagem: 'Adicione uma tarefa ou escolha uma trilha para começar.',
          )
        else ...[
          if (atrasadas.isNotEmpty) ...[
            _AvisoAtrasadas(quantidade: atrasadas.length),
            const SizedBox(height: 12),
          ],
          Text('Pendentes', style: tema.textTheme.titleLarge),
          const SizedBox(height: 8),
          if (pendentes.isEmpty)
            const EstadoVazio(
              icone: Icons.celebration_outlined,
              cor: TaskyColors.amarelo,
              titulo: 'Tudo feito',
              mensagem: 'Nenhuma tarefa pendente. Aproveite o momento!',
            )
          else
            _ListaTarefas(tarefas: pendentes),
          if (concluidas.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Concluídas', style: tema.textTheme.titleLarge),
            const SizedBox(height: 8),
            _ListaTarefas(tarefas: concluidas),
          ],
        ],
      ],
    );
  }

  /// Pendentes: atrasadas primeiro (mais antigas na frente), depois as com
  /// data futura (mais próximas na frente), depois as sem data.
  static List<Tarefa> _ordenarPendentes(List<Tarefa> tarefas) {
    final atrasadas = <Tarefa>[];
    final comData = <Tarefa>[];
    final semData = <Tarefa>[];
    for (final t in tarefas) {
      if (t.atrasada()) {
        atrasadas.add(t);
      } else if (t.data != null) {
        comData.add(t);
      } else {
        semData.add(t);
      }
    }
    atrasadas.sort((a, b) => a.data!.compareTo(b.data!));
    comData.sort((a, b) => a.data!.compareTo(b.data!));
    return [...atrasadas, ...comData, ...semData];
  }
}

class _AvisoAtrasadas extends StatelessWidget {
  const _AvisoAtrasadas({required this.quantidade});

  final int quantidade;

  @override
  Widget build(BuildContext context) {
    final cor = TaskyColors.laranja;
    final texto = quantidade == 1
        ? 'Uma tarefa está atrasada.'
        : '$quantidade tarefas estão atrasadas.';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cor.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: cor),
          const SizedBox(width: 10),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}

class _ListaTarefas extends StatelessWidget {
  const _ListaTarefas({required this.tarefas});

  final List<Tarefa> tarefas;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [for (final t in tarefas) _ItemTarefa(tarefa: t)],
      ),
    );
  }
}

class _ItemTarefa extends StatelessWidget {
  const _ItemTarefa({required this.tarefa});

  final Tarefa tarefa;

  Future<void> _editar(BuildContext context) async {
    final controller = TaskyScope.of(context);
    final dados = await abrirFormularioTarefa(context, inicial: tarefa);
    if (dados == null) return;
    await controller.atualizarTarefa(
      tarefa.copyWith(
        titulo: dados.titulo,
        observacao: dados.observacao,
        categoria: dados.categoria,
        data: dados.data,
        xp: dados.xp,
        limparObservacao: dados.observacao == null,
        limparCategoria: dados.categoria == null,
        limparData: dados.data == null,
      ),
    );
  }

  Future<void> _excluir(BuildContext context) async {
    final controller = TaskyScope.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    final removida = await controller.removerTarefa(tarefa.id);
    if (removida == null) return;
    mensageiro.hideCurrentSnackBar();
    mensageiro.showSnackBar(
      SnackBar(
        content: Text('"${removida.tarefa.titulo}" foi excluída.'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () => controller.restaurarTarefa(
            removida.tarefa,
            posicao: removida.posicao,
          ),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _alternar(BuildContext context) async {
    final controller = TaskyScope.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    final bonus = await controller.alternarConclusao(tarefa.id);
    if (bonus > 0) {
      mensageiro.showSnackBar(
        SnackBar(
          content: Text(
            'Combo de ${RegrasXp.diasCombo} dias seguidos! +$bonus XP',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final atrasada = tarefa.atrasada();
    final cores = tema.colorScheme;
    final concluida = tarefa.concluida;

    final detalhes = <String>[
      if (tarefa.categoria != null) tarefa.categoria!,
      '+${tarefa.xp} XP',
      if (tarefa.data != null && !atrasada && !concluida)
        formatarDataTarefa(tarefa.data!),
    ].join(' · ');

    return Container(
      decoration: BoxDecoration(
        border: atrasada && !concluida
            ? Border(left: BorderSide(color: TaskyColors.laranja, width: 4))
            : null,
      ),
      child: ListTile(
        leading: Checkbox(
          value: concluida,
          onChanged: (_) => _alternar(context),
        ),
        title: Text(
          tarefa.titulo,
          style: concluida
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: cores.onSurfaceVariant,
                )
              : null,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (detalhes.isNotEmpty) Text(detalhes),
            if (tarefa.observacao != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  tarefa.observacao!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cores.onSurfaceVariant),
                ),
              ),
            if (atrasada && !concluida)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _BadgeAtrasada(dias: tarefa.diasDeAtraso()),
              ),
          ],
        ),
        isThreeLine: tarefa.observacao != null || atrasada && !concluida,
        trailing: PopupMenuButton<String>(
          tooltip: 'Opções',
          onSelected: (acao) =>
              acao == 'editar' ? _editar(context) : _excluir(context),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'editar', child: Text('Editar')),
            PopupMenuItem(value: 'excluir', child: Text('Excluir')),
          ],
        ),
        onTap: () => _editar(context),
      ),
    );
  }
}

class _BadgeAtrasada extends StatelessWidget {
  const _BadgeAtrasada({required this.dias});

  final int dias;

  @override
  Widget build(BuildContext context) {
    const cor = TaskyColors.laranja;
    final texto = dias <= 0
        ? 'Atrasada'
        : dias == 1
        ? 'Atrasada há 1 dia'
        : 'Atrasada há $dias dias';
    final limiteSemPerda = RegrasXp.diasParaPenalizar - 1;
    final ainda = dias <= limiteSemPerda;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cor.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ainda ? Icons.schedule : Icons.warning_amber,
            size: 14,
            color: cor,
          ),
          const SizedBox(width: 4),
          Text(texto, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

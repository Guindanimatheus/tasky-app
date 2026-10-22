import 'package:flutter/material.dart';

import '../data/trilhas_padrao.dart';
import '../models/trilha.dart';
import '../providers/tasky_controller.dart';
import '../theme/tasky_theme.dart';
import '../widgets/estado_vazio.dart';
import 'trilha_detalhe_screen.dart';

const _cores = [TaskyColors.verde, TaskyColors.amarelo, TaskyColors.laranja];

class TrilhasScreen extends StatelessWidget {
  const TrilhasScreen({super.key, this.trilhas = trilhasPadrao});

  final List<Trilha> trilhas;

  @override
  Widget build(BuildContext context) {
    final controller = TaskyScope.of(context);
    final tema = Theme.of(context);
    if (trilhas.isEmpty) {
      return const ConteudoAba(
        children: [
          EstadoVazio(
            icone: Icons.map_outlined,
            cor: TaskyColors.laranja,
            titulo: 'Nenhuma trilha',
            mensagem: 'Ainda não há trilhas disponíveis.',
          ),
        ],
      );
    }
    return ConteudoAba(
      children: [
        Text('Escolha uma trilha', style: tema.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Cada trilha é uma sugestão de rotina. Você pode ajustar as tarefas '
          'do jeito que fizer sentido para você.',
          style: tema.textTheme.bodyLarge?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < trilhas.length; i++)
          _CartaoTrilha(
            trilha: trilhas[i],
            cor: _cores[i % _cores.length],
            selecionada: controller.trilhaId == trilhas[i].id,
            quantidade: controller.tarefasDaTrilha(trilhas[i]).length,
          ),
      ],
    );
  }
}

class _CartaoTrilha extends StatelessWidget {
  const _CartaoTrilha({
    required this.trilha,
    required this.cor,
    required this.selecionada,
    required this.quantidade,
  });

  final Trilha trilha;
  final Color cor;
  final bool selecionada;
  final int quantidade;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: selecionada
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: cor, width: 2),
            )
          : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrilhaDetalheScreen(trilha: trilha, cor: cor),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag_outlined, color: cor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(trilha.nome, style: tema.textTheme.titleLarge),
                  ),
                  if (selecionada)
                    Chip(
                      label: const Text('Atual'),
                      side: BorderSide(color: cor),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(trilha.descricao, style: tema.textTheme.bodyMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _Info(icone: Icons.schedule, texto: trilha.duracao),
                  _Info(
                    icone: Icons.speed,
                    texto: 'Dificuldade ${trilha.dificuldade.nome}',
                  ),
                  _Info(
                    icone: Icons.checklist,
                    texto: quantidade == 1 ? '1 tarefa' : '$quantidade tarefas',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 16, color: cor),
        const SizedBox(width: 4),
        Text(texto, style: TextStyle(color: cor)),
      ],
    );
  }
}

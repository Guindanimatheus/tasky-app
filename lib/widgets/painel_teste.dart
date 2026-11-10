import 'package:flutter/material.dart';

import '../models/estado_avatar.dart';
import '../providers/tasky_controller.dart';

// TEMPORÁRIO — este arquivo inteiro é andaime de desenvolvimento.
//
// Para tirar do app: ponha `modoTeste` em false.
// Para tirar do código: apague este arquivo, a chamada em
// inicio_screen.dart e o método definirXpParaTeste do TaskyController.

/// Liga o painel de teste. **Deixar `false` antes de publicar.**
const bool modoTeste = true;

/// Painel para percorrer os cinco moods sem concluir tarefas de verdade.
class PainelTeste extends StatelessWidget {
  const PainelTeste({super.key});

  /// XP escolhido para cada mood: o começo da faixa mais uma folga, para
  /// a barra de progresso não aparecer sempre zerada.
  static int _xpDoMood(EstadoAvatar e) =>
      e.xpMinimo + ((e.xpFinal - e.xpMinimo) * 0.3).round();

  @override
  Widget build(BuildContext context) {
    final controller = TaskyScope.of(context);
    final atual = EstadoAvatar.paraXp(controller.progresso.xp);
    final tema = Theme.of(context);

    return Card(
      color: tema.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: tema.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'MODO DE TESTE — sai antes de publicar',
                    style: tema.textTheme.labelMedium,
                  ),
                ),
                Text(
                  '${controller.progresso.xp} XP',
                  style: tema.textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final e in EstadoAvatar.values)
                  ChoiceChip(
                    label: Text('${e.numero}'),
                    tooltip: e.nome,
                    selected: e == atual,
                    onSelected: (_) =>
                        controller.definirXpParaTeste(_xpDoMood(e)),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 16),
                  label: const Text('50 XP'),
                  onPressed: () => controller.definirXpParaTeste(
                    controller.progresso.xp + 50,
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.remove, size: 16),
                  label: const Text('50 XP'),
                  onPressed: () => controller.definirXpParaTeste(
                    controller.progresso.xp - 50,
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.restart_alt, size: 16),
                  label: const Text('Zerar'),
                  onPressed: () => controller.definirXpParaTeste(0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

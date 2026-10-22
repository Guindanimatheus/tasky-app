import 'package:flutter/material.dart';

import '../models/estado_avatar.dart';
import '../models/progresso.dart';
import '../models/regras_xp.dart';
import '../providers/tasky_controller.dart';
import '../widgets/avatar_tasky.dart';
import '../widgets/estado_vazio.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final controller = TaskyScope.of(context);
    final xpReal = controller.progresso.xp;
    final sequencia = controller.sequenciaDias;
    // 1 a 5 dentro do combo atual (5 = acabou de fechar).
    final noCombo = sequencia == 0
        ? 0
        : (sequencia - 1) % RegrasXp.diasCombo + 1;

    // O XP exibido sobe aos poucos até o valor real; ao cruzar uma faixa,
    // o avatar muda de estado no caminho.
    return TweenAnimationBuilder<int>(
      tween: IntTween(end: xpReal),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (context, xp, _) {
        final proximo = EstadoAvatar.paraXp(xp).proximo;
        return ConteudoAba(
          children: [
            if (controller.perdaPorAtraso > 0) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.hourglass_bottom),
                  title: Text(
                    'Algumas tarefas ficaram para trás '
                    '(-${controller.perdaPorAtraso} XP).',
                  ),
                  subtitle: const Text(
                    'Tudo bem. Que tal recomeçar com uma tarefa pequena?',
                  ),
                  trailing: IconButton(
                    tooltip: 'Dispensar aviso',
                    icon: const Icon(Icons.close),
                    onPressed: controller.dispensarAvisoAtraso,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AvatarTasky(xp: xp),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nível ${Progresso(xp: xp).nivel}',
                      style: tema.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$xp de ${RegrasXp.xpMaximo} XP',
                      style: tema.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Combo: $noCombo de ${RegrasXp.diasCombo} dias '
                            'seguidos (+${RegrasXp.bonusCombo} XP ao fechar)',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      proximo == null
                          ? 'Você chegou ao último estado. Continue no seu ritmo.'
                          : 'Faltam ${proximo.xpMinimo - xp} XP para '
                                '"${proximo.nome}".',
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

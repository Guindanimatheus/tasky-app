import 'package:flutter/material.dart';

import '../theme/tasky_theme.dart';
import '../widgets/logo_tasky.dart';

/// Tela 01 do Figma: logo sobre Carvão e cartão roxo com carregamento.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.aoConcluir});

  final VoidCallback aoConcluir;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final _carregando = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    _carregando.forward().whenComplete(() {
      if (mounted) widget.aoConcluir();
    });
  }

  @override
  void dispose() {
    _carregando.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaskyColors.fundo,
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(child: Center(child: LogoTasky())),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TaskyColors.roxo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Transforme tarefas em conquistas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TaskyColors.superficieClara,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedBuilder(
                        animation: _carregando,
                        builder: (_, _) => LinearProgressIndicator(
                          value: _carregando.value,
                          minHeight: 6,
                          color: TaskyColors.superficieClara,
                          backgroundColor: TaskyColors.fundo,
                          borderRadius: BorderRadius.circular(3),
                          semanticsLabel: 'Carregando',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Carregando...',
                        style: TextStyle(
                          color: TaskyColors.superficieClara.withValues(
                            alpha: 0.75,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

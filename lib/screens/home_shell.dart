import 'package:flutter/material.dart';

import '../widgets/dialogos.dart';
import 'inicio_screen.dart';
import 'tarefas_screen.dart';
import 'trilhas_screen.dart';

/// Estrutura principal com navegação inferior entre as três abas.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.aoSair});

  final Future<void> Function()? aoSair;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _titulos = ['Tasky', 'Trilhas', 'Tarefas'];

  int _aba = 0;

  Future<void> _sair() async {
    final ok = await confirmar(
      context,
      titulo: 'Sair da conta?',
      mensagem: 'Suas tarefas e seu progresso continuam salvos neste aparelho.',
      rotuloConfirmar: 'Sair',
    );
    if (ok) await widget.aoSair!();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_aba]),
        actions: [
          if (widget.aoSair != null)
            IconButton(
              tooltip: 'Sair',
              icon: const Icon(Icons.logout),
              onPressed: _sair,
            ),
        ],
      ),
      // IndexedStack mantém o estado (ex.: rolagem) de cada aba.
      body: IndexedStack(
        index: _aba,
        children: const [InicioScreen(), TrilhasScreen(), TarefasScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Trilhas',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tarefas',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'providers/tasky_controller.dart';
import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';
import 'screens/splash_screen.dart';
import 'services/armazenamento.dart';
import 'services/conta_local.dart';
import 'theme/tasky_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final armazenamento = await Armazenamento.abrir();
  final conta = await ContaLocal.abrir();
  runApp(TaskyApp(controller: TaskyController(armazenamento), conta: conta));
}

class TaskyApp extends StatelessWidget {
  const TaskyApp({
    super.key,
    required this.controller,
    required this.conta,
    this.mostrarSplash = true,
  });

  final TaskyController controller;
  final ContaLocal conta;
  final bool mostrarSplash;

  @override
  Widget build(BuildContext context) {
    return TaskyScope(
      controller: controller,
      child: MaterialApp(
        title: 'Tasky',
        debugShowCheckedModeBanner: false,
        theme: TaskyTheme.escuro,
        home: _Raiz(conta: conta, mostrarSplash: mostrarSplash),
      ),
    );
  }
}

/// Splash → login/cadastro (se não houver sessão) → app.
class _Raiz extends StatefulWidget {
  const _Raiz({required this.conta, required this.mostrarSplash});

  final ContaLocal conta;
  final bool mostrarSplash;

  @override
  State<_Raiz> createState() => _RaizState();
}

class _RaizState extends State<_Raiz> {
  late bool _splash = widget.mostrarSplash;

  @override
  Widget build(BuildContext context) {
    if (_splash) {
      return SplashScreen(aoConcluir: () => setState(() => _splash = false));
    }
    return ListenableBuilder(
      listenable: widget.conta,
      builder: (context, _) => widget.conta.logado
          ? HomeShell(aoSair: widget.conta.sair)
          : AuthScreen(conta: widget.conta),
    );
  }
}

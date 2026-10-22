import 'package:flutter/material.dart';

/// Pede um título ao usuário. Retorna null se cancelar.
/// Títulos em branco não são aceitos.
Future<String?> pedirTitulo(
  BuildContext context, {
  required String titulo,
  String inicial = '',
  String rotuloConfirmar = 'Salvar',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _DialogoTitulo(
      titulo: titulo,
      inicial: inicial,
      rotuloConfirmar: rotuloConfirmar,
    ),
  );
}

/// Pergunta antes de uma ação. Retorna true só se o usuário confirmar.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  String rotuloConfirmar = 'Confirmar',
  String rotuloCancelar = 'Cancelar',
  bool destrutivo = false,
}) async {
  final cores = Theme.of(context).colorScheme;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(rotuloCancelar),
        ),
        FilledButton(
          style: destrutivo
              ? FilledButton.styleFrom(
                  backgroundColor: cores.error,
                  foregroundColor: cores.onError,
                )
              : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(rotuloConfirmar),
        ),
      ],
    ),
  );
  return ok ?? false;
}

class _DialogoTitulo extends StatefulWidget {
  const _DialogoTitulo({
    required this.titulo,
    required this.inicial,
    required this.rotuloConfirmar,
  });

  final String titulo;
  final String inicial;
  final String rotuloConfirmar;

  @override
  State<_DialogoTitulo> createState() => _DialogoTituloState();
}

class _DialogoTituloState extends State<_DialogoTitulo> {
  final _form = GlobalKey<FormState>();
  late final _texto = TextEditingController(text: widget.inicial);

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_form.currentState!.validate()) {
      Navigator.pop(context, _texto.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: Form(
        key: _form,
        child: TextFormField(
          controller: _texto,
          autofocus: true,
          maxLength: 80,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Título'),
          validator: (v) => v == null || v.trim().isEmpty
              ? 'Escreva um título para a tarefa.'
              : null,
          onFieldSubmitted: (_) => _salvar(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _salvar, child: Text(widget.rotuloConfirmar)),
      ],
    );
  }
}

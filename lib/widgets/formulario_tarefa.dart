import 'package:flutter/material.dart';

import '../models/regras_xp.dart';
import '../models/tarefa.dart';

/// Dados que o formulário produz. É usado tanto para criar (`inicial`
/// null) quanto para editar (`inicial` com a tarefa atual).
class DadosTarefa {
  const DadosTarefa({
    required this.titulo,
    this.observacao,
    this.categoria,
    this.data,
    this.xp = RegrasXp.xpTarefaPropria,
  });

  final String titulo;
  final String? observacao;
  final String? categoria;
  final DateTime? data;
  final int xp;
}

/// Categorias sugeridas, só como atalho. O usuário também pode digitar.
const categoriasSugeridas = [
  'Autocuidado',
  'Organização',
  'Movimento',
  'Foco',
  'Estudos',
  'Trabalho',
  'Pausa',
];

/// Abre um formulário em modal. Retorna `null` se o usuário cancelar.
Future<DadosTarefa?> abrirFormularioTarefa(
  BuildContext context, {
  Tarefa? inicial,
}) {
  return showModalBottomSheet<DadosTarefa>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _FormularioTarefa(inicial: inicial),
    ),
  );
}

class _FormularioTarefa extends StatefulWidget {
  const _FormularioTarefa({this.inicial});

  final Tarefa? inicial;

  @override
  State<_FormularioTarefa> createState() => _FormularioTarefaState();
}

class _FormularioTarefaState extends State<_FormularioTarefa> {
  final _form = GlobalKey<FormState>();
  late final _titulo = TextEditingController(
    text: widget.inicial?.titulo ?? '',
  );
  late final _observacao = TextEditingController(
    text: widget.inicial?.observacao ?? '',
  );
  late final _categoria = TextEditingController(
    text: widget.inicial?.categoria ?? '',
  );

  late DateTime? _data = widget.inicial?.data;
  late int _xp = widget.inicial?.xp ?? RegrasXp.xpTarefaPropria;

  @override
  void dispose() {
    _titulo.dispose();
    _observacao.dispose();
    _categoria.dispose();
    super.dispose();
  }

  bool get _editando => widget.inicial != null;

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data ?? hoje,
      firstDate: hoje.subtract(const Duration(days: 365)),
      lastDate: hoje.add(const Duration(days: 365 * 3)),
      helpText: 'Para quando é essa tarefa?',
      cancelText: 'Sem data',
    );
    if (escolhida != null) setState(() => _data = escolhida);
  }

  String? _texto(String? v) => v == null || v.trim().isEmpty ? null : v.trim();

  void _salvar() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
      context,
      DadosTarefa(
        titulo: _titulo.text.trim(),
        observacao: _texto(_observacao.text),
        categoria: _texto(_categoria.text),
        data: _data,
        xp: _xp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Form(
      key: _form,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _editando ? 'Editar tarefa' : 'Nova tarefa',
              style: tema.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titulo,
              autofocus: !_editando,
              maxLength: 80,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ex.: Ler 10 páginas',
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Escreva um título para a tarefa.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observacao,
              maxLength: 200,
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Observação (opcional)',
                hintText: 'Detalhes que te ajudam a lembrar.',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoria,
              maxLength: 24,
              decoration: const InputDecoration(
                labelText: 'Categoria (opcional)',
                hintText: 'Ex.: Autocuidado',
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: [
                for (final c in categoriasSugeridas)
                  _ChipCategoria(
                    rotulo: c,
                    selecionado: _categoria.text == c,
                    aoTocar: () => setState(() => _categoria.text = c),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _LinhaInfo(
              icone: Icons.event_outlined,
              rotulo: 'Data',
              valor: _data == null ? 'Sem data' : _formatarData(_data!),
              acao: TextButton(
                onPressed: _escolherData,
                child: Text(_data == null ? 'Escolher' : 'Trocar'),
              ),
              limpar: _data == null ? null : () => setState(() => _data = null),
            ),
            const SizedBox(height: 8),
            _LinhaInfo(
              icone: Icons.bolt_outlined,
              rotulo: 'XP',
              valor: '$_xp XP ao concluir',
              acao: null,
              limpar: null,
            ),
            Slider(
              value: _xp.toDouble(),
              min: 5,
              max: 30,
              divisions: 5,
              label: '$_xp XP',
              onChanged: (v) => setState(() => _xp = v.round()),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _salvar,
                    child: Text(_editando ? 'Salvar' : 'Adicionar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Fim do formulário.

class _ChipCategoria extends StatelessWidget {
  const _ChipCategoria({
    required this.rotulo,
    required this.selecionado,
    required this.aoTocar,
  });

  final String rotulo;
  final bool selecionado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(rotulo),
      selected: selecionado,
      onSelected: (_) => aoTocar(),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  const _LinhaInfo({
    required this.icone,
    required this.rotulo,
    required this.valor,
    required this.acao,
    required this.limpar,
  });

  final IconData icone;
  final String rotulo;
  final String valor;
  final Widget? acao;
  final VoidCallback? limpar;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icone, size: 20, color: cores.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rotulo, style: TextStyle(color: cores.onSurfaceVariant)),
              Text(valor),
            ],
          ),
        ),
        if (limpar != null)
          IconButton(
            tooltip: 'Remover',
            icon: const Icon(Icons.close),
            onPressed: limpar!,
          ),
        ?acao,
      ],
    );
  }
}

String _formatarData(DateTime d) {
  const meses = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];
  final hoje = DateTime.now();
  final soData = DateTime(d.year, d.month, d.day);
  final hojeSo = DateTime(hoje.year, hoje.month, hoje.day);
  final dif = soData.difference(hojeSo).inDays;
  if (dif == 0) return 'Hoje';
  if (dif == 1) return 'Amanhã';
  if (dif == -1) return 'Ontem';
  return '${d.day} de ${meses[d.month - 1]} de ${d.year}';
}

String formatarDataTarefa(DateTime d) => _formatarData(d);

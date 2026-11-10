import 'package:flutter/widgets.dart';

import '../data/trilhas_padrao.dart';
import '../models/progresso.dart';
import '../models/regras_xp.dart';
import '../models/tarefa.dart';
import '../models/trilha.dart';
import '../services/armazenamento.dart';

/// Estado do app e regras de negócio (tarefas, trilha, XP).
/// As telas só leem o estado e chamam estes métodos.
class TaskyController extends ChangeNotifier {
  TaskyController(this._armazenamento, {DateTime Function()? relogio})
    : _agora = relogio ?? DateTime.now {
    final dados = _armazenamento.carregar();
    _tarefas = List.of(dados.tarefas);
    _trilhaId = dados.trilhaId;
    _progresso = dados.progresso;
    _personalizadas = {
      for (final e in dados.trilhasPersonalizadas.entries)
        e.key: List.of(e.value),
    };
    _diasAtivos = Set.of(dados.diasAtivos);
    _ultimoCombo = dados.ultimoCombo;
    perdaPorAtraso = _aplicarPenalidades();
    if (perdaPorAtraso > 0) _salvarPenalidades();
  }

  final DateTime Function() _agora;

  final Armazenamento _armazenamento;

  late List<Tarefa> _tarefas;
  String? _trilhaId;
  late Progresso _progresso;
  late Map<String, List<TarefaModelo>> _personalizadas;
  late Set<String> _diasAtivos;
  String? _ultimoCombo;

  /// XP perdido por atrasos na última verificação (para avisar com
  /// gentileza na tela inicial). Zera quando o aviso é dispensado.
  int perdaPorAtraso = 0;
  int _contadorId = 0;

  List<Tarefa> get tarefas => List.unmodifiable(_tarefas);
  String? get trilhaId => _trilhaId;
  Progresso get progresso => _progresso;

  List<Tarefa> get pendentes => _tarefas.where((t) => !t.concluida).toList();
  List<Tarefa> get concluidas => _tarefas.where((t) => t.concluida).toList();

  Future<Tarefa> adicionarTarefa({
    required String titulo,
    String? observacao,
    String? categoria,
    DateTime? data,
    int xp = RegrasXp.xpTarefaPropria,
    String? trilhaId,
  }) async {
    final tarefa = Tarefa(
      id: _novoId(),
      titulo: titulo.trim(),
      observacao: _limpo(observacao),
      categoria: _limpo(categoria),
      data: data,
      xp: xp < 0 ? 0 : xp,
      trilhaId: trilhaId,
    );
    _tarefas.add(tarefa);
    await _salvarTarefas();
    return tarefa;
  }

  Future<void> atualizarTarefa(Tarefa tarefa) async {
    final i = _indice(tarefa.id);
    if (i < 0) return;
    // Preserva o controle de XP: edição nunca reabre o ganho.
    _tarefas[i] = tarefa.copyWith(
      xpConcedido: _tarefas[i].xpConcedido || tarefa.xpConcedido,
    );
    await _salvarTarefas();
  }

  /// Remove e devolve a tarefa + a posição em que ela estava, para que
  /// a tela possa oferecer "Desfazer" sem perder a ordem.
  Future<({Tarefa tarefa, int posicao})?> removerTarefa(String id) async {
    final i = _indice(id);
    if (i < 0) return null;
    final removida = _tarefas.removeAt(i);
    await _salvarTarefas();
    return (tarefa: removida, posicao: i);
  }

  /// Reinsere uma tarefa removida (usado pelo "Desfazer").
  Future<void> restaurarTarefa(Tarefa tarefa, {int? posicao}) async {
    // Se a tarefa já foi reinserida ou substituída, não duplica.
    if (_indice(tarefa.id) >= 0) return;
    final p = (posicao ?? _tarefas.length).clamp(0, _tarefas.length);
    _tarefas.insert(p, tarefa);
    await _salvarTarefas();
  }

  /// Conclui ou reabre. O XP é concedido só na primeira conclusão;
  /// reabrir não tira XP e concluir de novo não soma outra vez.
  /// Retorna o bônus de combo ganho nesta conclusão (0 se nenhum).
  Future<int> alternarConclusao(String id) async {
    final i = _indice(id);
    if (i < 0) return 0;
    final atual = _tarefas[i];
    var bonus = 0;

    if (atual.concluida) {
      _tarefas[i] = atual.copyWith(concluida: false);
    } else {
      final ganhaXp = !atual.xpConcedido;
      _tarefas[i] = atual.copyWith(concluida: true, xpConcedido: true);
      if (ganhaXp) _progresso = _progresso.ganhar(atual.xp);
      bonus = _registrarDiaAtivo();
      _progresso = _progresso.ganhar(bonus);
      await _armazenamento.salvarProgresso(_progresso);
      await _armazenamento.salvarCombo(_diasOrdenados(), _ultimoCombo);
    }
    await _salvarTarefas();
    return bonus;
  }

  /// Dias seguidos com ao menos uma conclusão, terminando hoje ou ontem
  /// (o combo de hoje ainda pode continuar).
  int get sequenciaDias {
    final hoje = _soData(_agora());
    var dia = _diasAtivos.contains(_chaveDia(hoje))
        ? hoje
        : hoje.subtract(const Duration(days: 1));
    var n = 0;
    while (_diasAtivos.contains(_chaveDia(dia))) {
      n++;
      dia = dia.subtract(const Duration(days: 1));
    }
    return n;
  }

  /// Marca hoje como ativo e devolve o bônus se fechou um combo.
  int _registrarDiaAtivo() {
    final hoje = _chaveDia(_agora());
    _diasAtivos.add(hoje);
    final seq = sequenciaDias;
    if (seq > 0 && seq % RegrasXp.diasCombo == 0 && _ultimoCombo != hoje) {
      _ultimoCombo = hoje;
      return RegrasXp.bonusCombo;
    }
    return 0;
  }

  List<String> _diasOrdenados() {
    final dias = _diasAtivos.toList()..sort();
    // Guarda só o necessário para calcular a sequência.
    return dias.length > 60 ? dias.sublist(dias.length - 60) : dias;
  }

  /// Dificuldade que vale para a tarefa: a da trilha de origem, ou a da
  /// trilha escolhida (tarefas próprias). Sem trilha, conta como leve.
  Dificuldade dificuldadeDe(Tarefa t) =>
      (trilhaPorId(t.trilhaId) ?? trilhaPorId(_trilhaId))?.dificuldade ??
      Dificuldade.leve;

  /// Tira XP, uma única vez, das tarefas muito atrasadas.
  /// Chamada ao abrir o app; também pode ser chamada depois.
  Future<int> verificarAtrasos() async {
    final perda = _aplicarPenalidades();
    if (perda > 0) {
      perdaPorAtraso += perda;
      await _salvarPenalidades();
    }
    return perda;
  }

  int _aplicarPenalidades() {
    var total = 0;
    final agora = _agora();
    for (var i = 0; i < _tarefas.length; i++) {
      final t = _tarefas[i];
      if (t.penalizada || t.diasDeAtraso(agora) < RegrasXp.diasParaPenalizar) {
        continue;
      }
      _tarefas[i] = t.copyWith(penalizada: true);
      total += dificuldadeDe(t).perdaPara(t.xp);
    }
    _progresso = _progresso.perder(total);
    return total;
  }

  Future<void> _salvarPenalidades() async {
    await _armazenamento.salvarProgresso(_progresso);
    await _salvarTarefas();
  }

  /// TEMPORÁRIO — usado só pelo PainelTeste, para percorrer os cinco
  /// moods sem ter que concluir tarefas. Sai junto com o painel.
  Future<void> definirXpParaTeste(int xp) async {
    _progresso = Progresso(xp: xp.clamp(0, RegrasXp.xpMaximo));
    notifyListeners();
    await _armazenamento.salvarProgresso(_progresso);
  }

  void dispensarAvisoAtraso() {
    perdaPorAtraso = 0;
    notifyListeners();
  }

  /// Tarefas da trilha: a versão personalizada, se houver, ou a padrão.
  List<TarefaModelo> tarefasDaTrilha(Trilha trilha) =>
      List.unmodifiable(_personalizadas[trilha.id] ?? trilha.tarefas);

  bool trilhaPersonalizada(Trilha trilha) =>
      _personalizadas.containsKey(trilha.id);

  /// Inclui uma tarefa na trilha. Títulos em branco são ignorados.
  Future<void> incluirTarefaNaTrilha(Trilha trilha, String titulo) async {
    final limpo = titulo.trim();
    if (limpo.isEmpty) return;
    await _editarTrilha(trilha, (l) => l.add(TarefaModelo(titulo: limpo)));
  }

  Future<void> editarTarefaDaTrilha(
    Trilha trilha,
    int indice,
    String titulo,
  ) async {
    final limpo = titulo.trim();
    if (limpo.isEmpty) return;
    await _editarTrilha(trilha, (l) {
      if (indice >= 0 && indice < l.length) {
        l[indice] = l[indice].comTitulo(limpo);
      }
    });
  }

  Future<void> removerTarefaDaTrilha(Trilha trilha, int indice) =>
      _editarTrilha(trilha, (l) {
        if (indice >= 0 && indice < l.length) l.removeAt(indice);
      });

  /// Volta a trilha às tarefas originais.
  Future<void> restaurarTrilha(Trilha trilha) async {
    if (_personalizadas.remove(trilha.id) == null) return;
    notifyListeners();
    await _armazenamento.salvarTrilhasPersonalizadas(_personalizadas);
  }

  Future<void> _editarTrilha(
    Trilha trilha,
    void Function(List<TarefaModelo>) alterar,
  ) async {
    final lista = List.of(_personalizadas[trilha.id] ?? trilha.tarefas);
    alterar(lista);
    _personalizadas[trilha.id] = lista;
    notifyListeners();
    await _armazenamento.salvarTrilhasPersonalizadas(_personalizadas);
  }

  /// Seleciona a trilha. Se [adicionarTarefas], inclui na lista as tarefas
  /// da trilha que ainda não existem, sem apagar as atuais.
  /// Retorna quantas tarefas foram adicionadas.
  Future<int> selecionarTrilha(
    Trilha trilha, {
    bool adicionarTarefas = true,
  }) async {
    _trilhaId = trilha.id;
    var adicionadas = 0;
    if (adicionarTarefas) {
      for (final modelo in tarefasDaTrilha(trilha)) {
        final existe = _tarefas.any(
          (t) => t.trilhaId == trilha.id && t.titulo == modelo.titulo,
        );
        if (!existe) {
          _tarefas.add(
            Tarefa(
              id: _novoId(),
              titulo: modelo.titulo,
              categoria: modelo.categoria,
              xp: trilha.dificuldade.xpPorTarefa,
              trilhaId: trilha.id,
            ),
          );
          adicionadas++;
        }
      }
    }
    await _armazenamento.salvarTrilha(_trilhaId);
    await _salvarTarefas();
    return adicionadas;
  }

  Future<void> limparTrilha() async {
    _trilhaId = null;
    await _armazenamento.salvarTrilha(null);
    notifyListeners();
  }

  Future<void> _salvarTarefas() async {
    notifyListeners();
    await _armazenamento.salvarTarefas(_tarefas);
  }

  static DateTime _soData(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _chaveDia(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  int _indice(String id) => _tarefas.indexWhere((t) => t.id == id);

  String _novoId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_contadorId++}';

  static String? _limpo(String? v) {
    final t = v?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}

/// Disponibiliza o [TaskyController] para a árvore de widgets.
class TaskyScope extends InheritedNotifier<TaskyController> {
  const TaskyScope({
    super.key,
    required TaskyController controller,
    required super.child,
  }) : super(notifier: controller);

  static TaskyController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TaskyScope>()!.notifier!;
}

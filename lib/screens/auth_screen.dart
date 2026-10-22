import 'package:flutter/material.dart';

import '../services/conta_local.dart';
import '../theme/tasky_theme.dart';
import '../widgets/logo_tasky.dart';

const _lilas = Color(0xFFECE6F7);
const _cinza = Color(0xFF6B6577);
const _tinta = Color(0xFF1F1A2B);

/// Tela 02 do Figma: abas "Entrar" e "Criar conta" na mesma estrutura.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.conta});

  final ContaLocal conta;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmar = TextEditingController();

  late bool _cadastro = !widget.conta.temConta;
  bool _ocultarSenha = true;
  bool _enviando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _email.text = widget.conta.email ?? '';
  }

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  void _trocarAba(bool cadastro) {
    if (cadastro == _cadastro) return;
    setState(() {
      _cadastro = cadastro;
      _erro = null;
      _confirmar.clear();
    });
    _form.currentState?.reset();
  }

  Future<void> _enviar() async {
    setState(() => _erro = null);
    if (!_form.currentState!.validate()) return;
    setState(() => _enviando = true);
    final erro = _cadastro
        ? await widget.conta.cadastrar(_email.text, _senha.text)
        : await widget.conta.entrar(_email.text, _senha.text);
    if (!mounted) return;
    setState(() {
      _enviando = false;
      _erro = erro;
    });
  }

  void _google() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('O login com Google chega em uma próxima versão.'),
      ),
    );
  }

  void _esqueciSenha() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Esqueci minha senha'),
        content: const Text(
          'Sua conta fica guardada só neste aparelho, por isso ainda não '
          'conseguimos enviar um e-mail de recuperação. Essa opção chega '
          'junto com a sincronização online.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: TaskyColors.roxo,
        primary: TaskyColors.roxo,
        error: const Color(0xFFC62828),
        surface: TaskyColors.superficieClara,
      ),
      scaffoldBackgroundColor: TaskyColors.superficieClara,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDD6E8)),
        ),
      ),
    );

    return Theme(
      data: tema,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Cabecalho(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: _formulario(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formulario(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Abas(cadastro: _cadastro, aoTrocar: _trocarAba),
          const SizedBox(height: 20),
          const _Rotulo('E-mail'),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(hintText: 'ana@email.com'),
            validator: ContaLocal.validarEmail,
          ),
          const SizedBox(height: 14),
          const _Rotulo('Senha'),
          TextFormField(
            controller: _senha,
            obscureText: _ocultarSenha,
            autofillHints: [
              _cadastro ? AutofillHints.newPassword : AutofillHints.password,
            ],
            textInputAction: _cadastro
                ? TextInputAction.next
                : TextInputAction.done,
            onFieldSubmitted: (_) => _cadastro ? null : _enviar(),
            decoration: InputDecoration(
              hintText: '••••••••',
              suffixIcon: IconButton(
                tooltip: _ocultarSenha ? 'Mostrar senha' : 'Ocultar senha',
                icon: Icon(
                  _ocultarSenha ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
              ),
            ),
            validator: ContaLocal.validarSenha,
          ),
          if (_cadastro) ...[
            const SizedBox(height: 14),
            const _Rotulo('Confirmar a senha'),
            TextFormField(
              controller: _confirmar,
              obscureText: _ocultarSenha,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _enviar(),
              decoration: const InputDecoration(hintText: '••••••••'),
              validator: (v) =>
                  v != _senha.text ? 'As senhas não são iguais.' : null,
            ),
          ] else
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _esqueciSenha,
                child: const Text('Esqueci minha senha'),
              ),
            ),
          const SizedBox(height: 16),
          if (_erro != null) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                _erro!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: _enviando ? null : _enviar,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            child: Text(_cadastro ? 'CADASTRAR' : 'ENTRAR E CONTINUAR'),
          ),
          const SizedBox(height: 16),
          const Text(
            'ou continue com',
            textAlign: TextAlign.center,
            style: TextStyle(color: _cinza, fontSize: 12),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _google,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: Colors.white,
              foregroundColor: _tinta,
              side: const BorderSide(color: Color(0xFFDDD6E8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'G   Continuar com Google',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                _cadastro ? 'Já tem conta?' : 'Ainda não tem conta?',
                style: const TextStyle(color: _cinza),
              ),
              TextButton(
                onPressed: () => _trocarAba(!_cadastro),
                child: Text(_cadastro ? 'Faça o login' : 'Cadastre-se'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _lilas,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                CoracaoPixel(tamanho: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Suas escolhas de hoje, seu melhor amanhã.',
                    style: TextStyle(
                      color: TaskyColors.roxo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _lilas,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CoracaoPixel(tamanho: 22),
                  SizedBox(width: 8),
                  Text(
                    'TASKY',
                    style: TextStyle(
                      fontFamily: kFontePixel,
                      fontSize: 12,
                      color: _tinta,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              Text(
                'Bem-vindo ao Tasky!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _tinta,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Transforme pequenas tarefas em conquistas.',
                style: TextStyle(color: _cinza),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seletor "Entrar" / "Criar conta".
class _Abas extends StatelessWidget {
  const _Abas({required this.cadastro, required this.aoTrocar});

  final bool cadastro;
  final ValueChanged<bool> aoTrocar;

  @override
  Widget build(BuildContext context) {
    Widget aba(String texto, bool valor) {
      final ativa = cadastro == valor;
      return Expanded(
        child: Semantics(
          selected: ativa,
          button: true,
          child: Material(
            color: ativa ? TaskyColors.roxo : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => aoTrocar(valor),
              child: Container(
                height: 42,
                alignment: Alignment.center,
                child: Text(
                  texto,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ativa ? Colors.white : TaskyColors.roxo,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _lilas,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [aba('Entrar', false), aba('Criar conta', true)]),
    );
  }
}

class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        texto,
        style: const TextStyle(fontWeight: FontWeight.w700, color: _tinta),
      ),
    );
  }
}

# Tasky

Tarefas gamificadas com um mascote que reage ao seu ritmo.

Cada tarefa concluída dá XP. O XP define a fase do usuário, e o Tasky — um
gato animado — muda de expressão e de postura conforme essa fase: cabisbaixo
quando as coisas estão paradas, sorrindo quando o ritmo está bom.

**Versão web:** https://guindanimatheus.github.io/tasky-app/

## Funcionalidades

- **Conta local:** cadastro e login com e-mail e senha. A senha nunca é
  salva: o app guarda um hash SHA-256 com sal aleatório.
- **Tarefas:** criar, editar, excluir (com "desfazer"), concluir e reabrir.
  Cada tarefa pode ter observação, categoria, data e valor de XP. Concluir
  pede confirmação.
- **Atrasos:** tarefas vencidas aparecem primeiro e com destaque. A partir de
  2 dias de atraso, a tarefa passa a tirar XP.
- **Combo:** 5 dias seguidos com ao menos uma tarefa concluída dão +100 XP.
- **Trilhas:** cinco sequências prontas de tarefas, da mais leve à mais
  exigente. Quanto mais difícil a trilha, mais XP cada tarefa vale — e mais se
  perde por atraso.
- **Mascote interativo:** o Tasky respira, pisca, reage ao toque e troca de
  expressão em cada fase. O cenário ao fundo também muda.
- **Offline:** todos os dados ficam no próprio aparelho.

## Fases do mascote

| XP        | Fase             |
|-----------|------------------|
| 0–199     | O Procrastinador |
| 200–399   | Piorando         |
| 400–599   | Neutro           |
| 600–799   | Indo bem         |
| 800–1000  | Disciplinado     |

## Trilhas

| Trilha                | Dificuldade      | XP por tarefa | Perda por atraso |
|-----------------------|------------------|---------------|------------------|
| O Primeiro Passo      | Fácil            | 10            | nenhuma          |
| Organize sua Mente    | Fácil a moderada | 11            | 25%              |
| Domine seu Foco       | Moderada         | 12            | 50%              |
| Disciplina na Prática | Difícil          | 15            | 100%             |
| Alta Performance      | Avançada         | 18            | 100%             |

## Tecnologias

- [Flutter](https://flutter.dev) (Dart) — Android, web e Windows a partir do
  mesmo código.
- [Rive](https://rive.app) — animação do mascote, com máquina de estados
  ligada ao humor (`mood`) e ao toque (`tap`).
- `shared_preferences` — persistência local.
- `crypto` — hash da senha.

## Estrutura

```
lib/
  main.dart            entrada do app
  models/              tarefa, trilha, progresso, fases e regras de XP
  data/                trilhas prontas
  providers/           TaskyController: estado e regras do app
  services/            armazenamento local e conta
  screens/             splash, login, início, tarefas e trilhas
  widgets/             mascote, cenário, formulários e diálogos
  theme/               cores e tema
test/                  testes de widget e de regras
rive/tasky_v2/         fonte do mascote (cena RML e recortes da arte)
assets/mascote/        mascote compilado (.riv)
arte/                  arte original e notas de animação
```

## Como rodar

Requer o Flutter instalado (`flutter doctor` sem erros para a plataforma
desejada).

```bash
flutter pub get
flutter run -d chrome          # navegador
flutter run                    # celular conectado
flutter test                   # testes
flutter build apk --release    # APK em build/app/outputs/flutter-apk/
```

> **Windows:** rode os comandos a partir de `C:\...` com a letra do drive em
> maiúscula. Com `c:\...` o Flutter gera o build web sem os assets.

## Modo de demonstração

O painel de teste na tela inicial permite saltar entre as cinco fases sem
concluir tarefas de verdade, para mostrar o mascote mudando. Ele é ligado por
`modoTeste` em `lib/widgets/painel_teste.dart`; desligue antes de uma versão
final.

## Limitações conhecidas

- Os dados ficam só no aparelho: não há servidor, sincronização nem
  recuperação de senha.
- O mascote troca a cabeça e a postura em cada fase, mas o corpo é o mesmo nas
  cinco.
- A versão atual do mascote foi exportada no plano gratuito do Rive e exibe a
  marca do Rive ao carregar.

import '../models/regras_xp.dart';
import '../models/trilha.dart';

/// Trilhas iniciais oferecidas no app.
///
/// Formam uma escada contra a procrastinação: começar, organizar, focar,
/// sustentar e, por fim, entregar. A dificuldade sobe junto, e com ela o
/// XP por tarefa e a perda por atraso (ver [Dificuldade]).
const trilhasPadrao = [
  Trilha(
    id: 'primeiro-passo',
    nome: 'O Primeiro Passo',
    descricao:
        'Está difícil sair do lugar? Comece pequeno. Nesta trilha, você vai '
        'aprender a vencer a inércia com pequenas ações diárias e descobrir '
        'que dar o primeiro passo pode ser mais fácil do que parece.',
    duracao: '7 dias',
    dificuldade: Dificuldade.leve,
    tarefas: [
      TarefaModelo(titulo: 'Arrumar a cama', categoria: 'Organização'),
      TarefaModelo(
        titulo: 'Beber um copo de água ao acordar',
        categoria: 'Autocuidado',
      ),
      TarefaModelo(
        titulo: 'Organizar a mesa por 2 minutos',
        categoria: 'Organização',
      ),
      TarefaModelo(
        titulo: 'Fazer uma tarefa que leve menos de 5 minutos',
        categoria: 'Foco',
      ),
      TarefaModelo(
        titulo: 'Guardar 5 objetos fora do lugar',
        categoria: 'Organização',
      ),
      TarefaModelo(
        titulo: 'Escolher uma prioridade para o dia',
        categoria: 'Foco',
      ),
      TarefaModelo(
        titulo: 'Começar por 2 minutos uma tarefa que você está adiando',
        categoria: 'Foco',
      ),
    ],
  ),
  Trilha(
    id: 'organize-sua-mente',
    nome: 'Organize sua Mente',
    descricao:
        'Quando tudo parece urgente, fica difícil saber por onde começar. '
        'Organize seus pensamentos, defina prioridades e transforme grandes '
        'responsabilidades em pequenas etapas.',
    duracao: '10 dias',
    dificuldade: Dificuldade.facilModerada,
    tarefas: [
      TarefaModelo(
        titulo: 'Escrever tudo o que precisa fazer',
        categoria: 'Organização',
      ),
      TarefaModelo(
        titulo: 'Escolher as 3 prioridades do dia',
        categoria: 'Foco',
      ),
      TarefaModelo(
        titulo: 'Dividir uma tarefa grande em 3 etapas',
        categoria: 'Organização',
      ),
      TarefaModelo(
        titulo: 'Organizar o ambiente antes de começar',
        categoria: 'Organização',
      ),
      TarefaModelo(
        titulo: 'Definir um horário para uma tarefa importante',
        categoria: 'Foco',
      ),
      TarefaModelo(
        titulo: 'Planejar o dia seguinte em 5 minutos',
        categoria: 'Organização',
      ),
      TarefaModelo(
        titulo: 'Eliminar uma tarefa desnecessária da lista',
        categoria: 'Organização',
      ),
    ],
  ),
  Trilha(
    id: 'domine-seu-foco',
    nome: 'Domine seu Foco',
    descricao:
        'Distrações roubam seu tempo e dificultam seu progresso. Aprenda a '
        'proteger sua atenção, reduzir interrupções e permanecer concentrado '
        'em uma tarefa de cada vez.',
    duracao: '14 dias',
    dificuldade: Dificuldade.media,
    tarefas: [
      TarefaModelo(
        titulo: 'Trabalhar em uma tarefa por 10 minutos sem interrupções',
        categoria: 'Foco',
      ),
      TarefaModelo(
        titulo: 'Deixar o celular longe durante uma sessão de foco',
        categoria: 'Foco',
      ),
      TarefaModelo(
        titulo: 'Desativar notificações não essenciais por 30 minutos',
        categoria: 'Foco',
      ),
      TarefaModelo(
        titulo: 'Concluir uma sessão de foco de 15 minutos',
        categoria: 'Foco',
      ),
      TarefaModelo(
        titulo: 'Fazer uma tarefa antes de abrir as redes sociais',
        categoria: 'Foco',
      ),
      TarefaModelo(
        titulo: 'Completar duas sessões de foco no mesmo dia',
        categoria: 'Foco',
      ),
      TarefaModelo(
        titulo: 'Identificar e evitar sua principal distração',
        categoria: 'Pausa',
      ),
    ],
  ),
  Trilha(
    id: 'disciplina-na-pratica',
    nome: 'Disciplina na Prática',
    descricao:
        'Você não precisa esperar a motivação aparecer para agir. Construa '
        'hábitos, cumpra seus compromissos e aprenda a continuar mesmo nos '
        'dias em que a vontade de desistir aparece.',
    duracao: '21 dias',
    dificuldade: Dificuldade.dificil,
    tarefas: [
      TarefaModelo(
        titulo: 'Cumprir o horário planejado para uma tarefa',
        categoria: 'Hábito',
      ),
      TarefaModelo(
        titulo: 'Manter uma rotina matinal por 3 dias',
        categoria: 'Hábito',
      ),
      TarefaModelo(
        titulo: 'Realizar primeiro a tarefa mais importante do dia',
        categoria: 'Foco',
      ),
      TarefaModelo(
        titulo: 'Estudar ou trabalhar com foco por 25 minutos',
        categoria: 'Foco',
      ),
      TarefaModelo(
        titulo: 'Cumprir uma tarefa mesmo sem estar motivado',
        categoria: 'Hábito',
      ),
      TarefaModelo(
        titulo: 'Manter um hábito durante 5 dias',
        categoria: 'Hábito',
      ),
      TarefaModelo(
        titulo: 'Retomar a rotina após perder um dia, sem desistir',
        categoria: 'Hábito',
      ),
    ],
  ),
  Trilha(
    id: 'alta-performance',
    nome: 'Alta Performance',
    descricao:
        'Você já aprendeu a começar, planejar e manter o foco. Agora é hora '
        'de assumir o controle das suas metas, organizar sua rotina e '
        'transformar seus planos em resultados concretos.',
    duracao: '30 dias',
    dificuldade: Dificuldade.avancada,
    tarefas: [
      TarefaModelo(
        titulo: 'Definir uma meta pessoal para os próximos 30 dias',
        categoria: 'Meta',
      ),
      TarefaModelo(
        titulo: 'Criar um plano semanal com prioridades',
        categoria: 'Organização',
      ),
      TarefaModelo(
        titulo: 'Dividir uma meta em pequenas entregas',
        categoria: 'Meta',
      ),
      TarefaModelo(
        titulo: 'Concluir uma tarefa importante antes do lazer planejado',
        categoria: 'Foco',
      ),
      TarefaModelo(
        titulo: 'Fazer uma revisão semanal dos resultados',
        categoria: 'Meta',
      ),
      TarefaModelo(
        titulo: 'Identificar padrões que levam à procrastinação',
        categoria: 'Pausa',
      ),
      TarefaModelo(
        titulo: 'Reservar tempo na agenda para um projeto pessoal',
        categoria: 'Meta',
      ),
      TarefaModelo(
        titulo: 'Concluir uma etapa de um projeto que estava parado',
        categoria: 'Meta',
      ),
    ],
  ),
];

Trilha? trilhaPorId(String? id) {
  for (final t in trilhasPadrao) {
    if (t.id == id) return t;
  }
  return null;
}

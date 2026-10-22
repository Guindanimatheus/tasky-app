import '../models/regras_xp.dart';
import '../models/trilha.dart';

/// Trilhas iniciais oferecidas no app.
const trilhasPadrao = [
  Trilha(
    id: 'recomeco-leve',
    nome: 'Recomeço leve',
    descricao: 'Para começar com pequenas ações diárias, no seu ritmo.',
    duracao: '7 dias',
    dificuldade: Dificuldade.leve,
    tarefas: [
      TarefaModelo(
        titulo: 'Beber um copo de água ao acordar',
        categoria: 'Autocuidado',
      ),
      TarefaModelo(
        titulo: 'Abrir a janela e respirar fundo',
        categoria: 'Autocuidado',
      ),
      TarefaModelo(titulo: 'Arrumar a cama', categoria: 'Organização'),
      TarefaModelo(titulo: 'Caminhar por 5 minutos', categoria: 'Movimento'),
      TarefaModelo(
        titulo: 'Anotar uma coisa boa do dia',
        categoria: 'Autocuidado',
      ),
    ],
  ),
  Trilha(
    id: 'rotina-equilibrada',
    nome: 'Rotina equilibrada',
    descricao: 'Para combinar autocuidado, organização e foco ao longo do dia.',
    duracao: '14 dias',
    dificuldade: Dificuldade.media,
    tarefas: [
      TarefaModelo(
        titulo: 'Alongar o corpo por 5 minutos',
        categoria: 'Autocuidado',
      ),
      TarefaModelo(
        titulo: 'Organizar um cantinho da casa',
        categoria: 'Organização',
      ),
      TarefaModelo(
        titulo: 'Dedicar 25 minutos a uma tarefa importante',
        categoria: 'Foco',
      ),
      TarefaModelo(
        titulo: 'Fazer uma refeição com calma',
        categoria: 'Autocuidado',
      ),
      TarefaModelo(
        titulo: 'Separar a roupa de amanhã',
        categoria: 'Organização',
      ),
      TarefaModelo(titulo: 'Revisar o dia antes de dormir', categoria: 'Foco'),
    ],
  ),
  Trilha(
    id: 'foco-total',
    nome: 'Foco total',
    descricao: 'Para uma rotina mais estruturada, com blocos de foco e pausas.',
    duracao: '21 dias',
    dificuldade: Dificuldade.dificil,
    tarefas: [
      TarefaModelo(
        titulo: 'Escolher as 3 prioridades do dia',
        categoria: 'Foco',
      ),
      TarefaModelo(titulo: 'Bloco de foco de 25 minutos', categoria: 'Foco'),
      TarefaModelo(
        titulo: 'Pausa de 5 minutos longe da tela',
        categoria: 'Pausa',
      ),
      TarefaModelo(
        titulo: 'Segundo bloco de foco de 25 minutos',
        categoria: 'Foco',
      ),
      TarefaModelo(
        titulo: 'Pausa longa para se movimentar',
        categoria: 'Pausa',
      ),
      TarefaModelo(titulo: 'Anotar o que avançou hoje', categoria: 'Foco'),
    ],
  ),
];

Trilha? trilhaPorId(String? id) {
  for (final t in trilhasPadrao) {
    if (t.id == id) return t;
  }
  return null;
}

# Arte do Tasky — especificação

Referência de produção. `arte/` fica **fora** de `assets/`, e o pubspec
agora lista arquivo por arquivo em vez da pasta inteira. Manter assim:
foi declarar `- assets/mascote/` que empacotou 17 MB de referência no
APK sem ninguém perceber.

```
arte/
  avatares/   um PNG por mood que muda de corpo, fundo transparente
  rostos/     variações de expressão, no enquadramento do corpo base
  frames/     folhas de referência de movimento (não viram pixel)
  cenario/    um quarto por mood, 1536x1024 (os cinco: prontos)
```

---

# O QUE FALTA CRIAR

**Os cinco corpos estão prontos.** Um por mood, com alfa, em
`arte/avatares/`, e já no app em `assets/avatar/moodN.webp`.

Quatro deles vieram com fundo preto chapado e foram recortados aqui
(ver "Recorte do fundo preto" mais abaixo). Os originais ficaram em
`arte/avatares/_fonte_fundo_preto/`, caso o corte precise ser refeito.

## 1. Decisão: pose de repouso dos moods 3 e 4

**Isto não é um arquivo, é uma escolha — e trava o rig.**

Os moods 3 e 4 vieram em poses de ação: o 3 fazendo joinha, o 4 com o
punho erguido, olhos fechados, rindo. Como estado de repouso elas não
funcionam — ninguém fica parado de joinha, e um punho no alto em loop
contínuo cansa em dez segundos.

Dois caminhos:

- **(a)** usar estas duas como **reação ao toque** e me mandar duas
  poses de repouso com braços soltos (o rosto pode ser o mesmo). Fica
  fiel ao que já foi planejado na folha de 17 frames, onde o braço
  levantado é gatilho, não repouso;
- **(b)** manter como repouso e eu desço o braço na animação,
  interpolando a partir da pose do mood 2. Não custa arte nova, mas o
  braço vai ficar visivelmente "de borracha" no meio do caminho, porque
  não existe desenho intermediário.

Recomendo **(a)**. Se for esse o caminho, faltam dois arquivos:
`mood3_indo_bem_repouso.png` e `mood4_disciplinado_repouso.png`,
1024x1536, braços soltos ao lado do corpo como no mood 2.

## 2. Rostos — talvez nenhum

A arte nova já traz rosto próprio em cada mood, então a lista antiga de
rostos avulsos **caiu**. Só continuam valendo se o caminho (b) acima
for escolhido, ou se você quiser expressões extras dentro de um mesmo
mood.

Os dois rostos de gatilho que eu tinha pedido **já vieram**: boca
aberta rindo (no mood 3) e olhos fechados de alegria (no mood 4).

Piscar comum e olhar pros lados **não precisam de arte**: a pálpebra
saiu gerada da própria cabeça (ver "Já recortado: as pálpebras") e a
íris é peça recortada que desliza dentro do olho.

## 3. Folhas de transição — reexportar para virar animação

A folha com as três transições (0→1, 2→3, 3→4) chegou e está fatiada em
`arte/frames/transicoes/`, 13 quadros por transição, alinhados pelos
pés. **Servem como referência de movimento, não como arte final.**
Dois impedimentos, ambos do arquivo de origem:

**Resolução.** O personagem tem 232 a 273 px de altura nos quadros. O
app precisa de:

| densidade de tela | altura necessária |
|---|---|
| 1x (navegador) | 216 px |
| 2x | 431 px |
| 3x (celular comum) | 647 px |

Num celular 3x o quadro teria que ser esticado 2,5x. Fica visivelmente
mole, e pior: a transição mole desaguaria na pose parada, que é nítida.
O corte entre as duas denuncia tudo.

**Recorte da cauda.** Os 39 quadros encostam nas **duas** bordas da
célula: as figuras transbordam e a cauda de cada uma é cortada pela
vizinha. Esses pixels não existem no arquivo, não há como recuperar.

A arte cheia tem razão largura/altura de 0.531. A folha oferece 0.442.
Cada célula precisaria ser **20% mais larga** (141 px em vez de 117).

### Como reexportar, se quiser transição desenhada

- **um arquivo por quadro**, não folha de contato;
- 1024x1536 cada, como os avatares (ou no mínimo personagem com 700 px
  de altura);
- fundo transparente, ou verde/magenta chapado;
- **nada encostando na borda** — cauda inteira dentro do quadro;
- mesma câmera, mesma escala e mesma linha de pés em todos os quadros
  de uma transição.

São 36 arquivos. **A alternativa é não desenhar nenhum**: montar as
transições no rig, usando estas folhas como referência de pose. O rig
desenha em qualquer resolução a partir das peças de 1024x1536, e não
tem problema de cauda cortada. É o caminho que eu recomendo.

## 4. Folhas de movimento — 3 arquivos

Pasta: `arte/frames/`. Já tenho a do mood 3 (17 frames) e a da
transição 1→2 (12 frames).

| arquivo | para quê |
|---|---|
| `mood1_piorando_Nframes.png` | o que se mexe no mood 1 |
| `mood2_neutro_Nframes.png` | o que se mexe no mood 2 |
| `mood4_disciplinado_Nframes.png` | o que se mexe no mood 4 |

O mood 0 não precisa: lá só há respiração.

A transição **1→2 não precisa de folha**: os moods 1 e 2 dividem o
quarto, e o que muda é só a expressão. Com as três folhas que chegaram,
as quatro viradas estão cobertas em referência.

## 5. Decisão pendente (não é arquivo)

O avatar está desenhado em luz quente. Os quartos 0 e 1 são frios e
chuvosos. Duas saídas:

- **(a)** a arte do mood 0 já vem com iluminação fria;
- **(b)** eu aplico uma tinta por mood no rig, sem arte nova.

(b) é mais barato e reversível, mas tinta chapada sobre um personagem
já sombreado costuma achatar o volume. Precisa da sua escolha.

---

## Regra dos arquivos

PNG com canal alfa de verdade, 1024x1536, personagem ocupando ~1500 px
de altura. **Fundo preto não serve** (ver item 1). Se o gerador não
mantiver alfa, usar verde ou magenta chapado.

## Estado por mood

| mood | corpo | rosto | folha de movimento | quarto |
|---|---|---|---|---|
| 0 Procrastinador | **falta com alfa** | junto do corpo | não precisa (só respira) | quarto 0 |
| 1 Piorando | base do mood 2 | **falta** | **falta** | quarto 1 |
| 2 Neutro | pronto | vem no corpo | **falta** | quarto 1 (dividido) |
| 3 Indo bem | base do mood 2 | **falta** | pronta (17 frames) | quarto 3 |
| 4 Disciplinado | base do mood 2 | **falta** | **falta** | quarto 4 |

## Movimentos

### Comum a todos
- **Respirar**: tronco sobe e desce. Loop contínuo, sempre ligado.
- **Orelhas**: peças próprias com rotação, em todos os moods — menos no
  mood 0, onde ficam caídas e paradas porque lá só há respiração.

### mood 0 — Procrastinador
Só respiração. Nada mais se move. Cabeça baixa, roupa manchada e rasgada.

### mood 3 — Indo bem
Folha de 17 frames. Repouso: sorriso leve de boca fechada.

| frames | o que é | tipo |
|---|---|---|
| 02–04 | piscar: fecha, fechado, abre | idle, aleatório ~4–7 s |
| 08–09 | olhar pra direita / esquerda | idle, ocasional |
| 10–11 | cabeça inclina pra direita / esquerda | idle, ocasional |
| 15–17 | cauda balançando, com rastro | loop contínuo |
| 12–14 | levanta o braço, punho fechado, volta | gatilho (tap) |
| 05–07 | sorriso leve → sorrindo → rindo | intensidade |

- A cauda tem arco: a ponta atrasa em relação à base. Pede duas peças
  ou dois ossos, não rotação rígida.
- O repouso tem que vir de **braços soltos**. Com as mãos no bolso não
  existe peça de braço pra levantar no gatilho.

## Cenários — prontos

Os quartos estão fechados. Mapeamento confirmado pela bicicleta na
parede, que aparece tanto no quarto 3 quanto na folha de movimento do
mood 3.

Originais em `arte/cenario/` (PNG 1536x1024, ~2 MB cada); no app em
`assets/cenario/moodN.webp`, WebP qualidade 85 na mesma resolução.

### Quatro quartos para cinco moods

| mood | quarto |
|---|---|
| 0 Procrastinador | `mood0.webp` |
| 1 Piorando | `mood1.webp` |
| 2 Neutro | `mood1.webp` — o mesmo |
| 3 Indo bem | `mood3.webp` |
| 4 Disciplinado | `mood4.webp` |

**O mood 2 divide o quarto com o mood 1.** Subir de Piorando para
Neutro muda só o humor do mascote; o cenário fica parado. A tabela está
em `CenarioTasky._quartoDoMood`, e o `didUpdateWidget` compara o
*quarto*, não o mood — então não há cross-fade de uma imagem para ela
mesma.

Não existe `assets/cenario/mood2.webp`. O PNG original continua em
`arte/cenario/quarto_2_neutro.png`, fora do app, caso volte a ser usado.

Os quatro que sobraram somam **562 KB** (eram 7,8 MB em PNG).

### Alinhamento de câmera

O que importa é a **base do tapete**, porque é onde os pés do mascote
pousam. Medida na faixa central de colunas (640–900):

| mood | topo do tapete | base do tapete |
|---|---|---|
| 0 | 636 | 983 |
| 1 | 635 | 981 |
| 2 | 594 | 979 |
| 3 | 635 | 981 |
| 4 | 634 | 981 |

**A base bate nos cinco** (variação de 4 px em 1024). Nenhuma correção
por quarto é necessária: o mascote usa uma única linha de chão.

O quarto 2 tem o topo do tapete 41 px mais alto, mas isso é ângulo de
câmera (o tapete é desenhado mais fundo), não deslocamento — e não
afeta onde os pés pousam.

> Correção de uma medição anterior: eu havia anotado "quarto 2 ~32 px
> desalinhado", vindo de correlação cruzada dos perfis de borda. Aquela
> medida estava dominada pela mobília diferente (o quarto 2 é vazio, o 3
> tem bicicleta e prateleiras), não pela câmera. O chão está alinhado.

### Luz

| mood | luminância | calor (R-B) | saturação |
|---|---|---|---|
| 0 | 60.5 | 40.1 | 0.510 |
| 1 | 62.7 | 36.5 | 0.467 |
| 2 | 99.3 | 79.5 | 0.579 |
| 3 | 72.6 | 61.7 | 0.614 |
| 4 | 71.0 | 71.0 | 0.687 |

O quarto 2 era o mais claro e o mais quente dos cinco: a curva subia e
descia no meio. **Resolvido tirando ele do app** — o mood 2 passou a
usar o quarto 1. Sobraram quatro quartos cuja luz só caminha para
frente:

| mood | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| luminância | 60.5 | 62.7 | 62.7 | 72.6 | 71.0 |
| calor | 40.1 | 36.5 | 36.5 | 61.7 | 71.0 |

A progressão do Tasky não é de brilho, é de aconchego: o calor dos
moods 3 e 4 vem de mobília, plantas e luminárias acesas, não de
exposição.

(Houve também uma versão graduada do quarto 2, que puxava a luminância
para 73.6. Descartada antes disso.)

## Arquitetura

Os quartos são assets do Flutter e o cross-fade acontece lá. O `.riv`
carrega só o personagem: nada no quarto se mexe, e cinco imagens de
1536x1024 dentro do `.riv` fariam cada ajuste de arte depender de um
rebuild do rig.

### Troca de quarto

Regra em `lib/widgets/cenario_tasky.dart`:

- **o usuário está na aba do avatar** → cross-fade de 700 ms, com o
  quarto antigo opaco embaixo e o novo entrando por cima (os dois
  trocando de opacidade ao mesmo tempo deixariam um vão escuro no meio);
- **o usuário está em outra aba** → troca seca, já entra atualizado;
- **"reduzir animações" ligado no sistema** → troca seca também, de
  graça: o `AnimationController` do Flutter obedece a essa preferência
  sozinho;
- **moods que dividem quarto (1 e 2)** → nada acontece com o cenário.

O `IndexedStack` do `HomeShell` mantém as três abas montadas o tempo
todo, então a tela do avatar não sabe sozinha se está à vista. O sinal
desce por `InicioScreen(visivel: _aba == 0)`.

### Posição do mascote no quarto

Constantes em `CenarioTasky`:

| constante | valor | o que é |
|---|---|---|
| `alturaMascotePadrao` | 0.77 | altura da caixa do mascote, em fração da altura do quarto |
| `linhaDoChaoPadrao` | 0.86 | onde ficam os pés, em fração da altura |
| `larguraMaximaDiorama` | 420 px | teto de largura (em `AvatarTasky`) |

0.86 cai na metade da frente do tapete nos quatro quartos. Os dois
primeiros valores são **ajuste visual** e vão pedir outro número quando
o rig novo (`rive/tasky_v2`) entrar, porque o enquadramento dele é
diferente do rig atual.

## Recorte do corpo base (mood 2)

Feito em `rive/tasky_v2/`, a partir de `arte/avatares/mood2_neutro.png`
em resolução cheia. Posições em `pecas.json`, na moldura 1024x1536.

Método: alfa dá a silhueta; luminância 90 separa pelo de roupa;
componentes conectados isolam cabeça, cauda e as duas patas. O contorno
preto do desenho vai para a peça que ele cerca (dilatação de 7 px) e as
sombras internas entram por preenchimento de buraco. O que sobra é
roupa, fatiada em y=826 (barra do moletom) e y=1365 (tornozelo), ambos
medidos no degrau de luz e conferidos no olho.

| peça | tamanho | posição |
|---|---|---|
| cabeca | 405 x 459 | 287, 8 |
| orelha_esq | 159 x 170 | 287, 93 |
| orelha_dir | 230 x 253 | 462, 8 |
| cauda | 370 x 303 | 629, 873 |
| pata_esq | 116 x 195 | 186, 760 |
| pata_dir | 142 x 203 | 659, 761 |
| tronco | 588 x 486 | 225, 340 |
| pernas | 491 x 539 | 311, 826 |
| tenis | 590 x 156 | 221, 1365 |

Remontagem confere pixel a pixel com o original dentro da silhueta:
zero diferença, zero pixel órfão.

As orelhas são **cópias** do que continua dentro da cabeça, não
recortes subtraídos: giram poucos graus por cima dela e não deixam
buraco. O polígono é um triângulo reto que entra um pouco no cabelo
espetado, porque as pontas da orelha são pretas e o cabelo se funde com
a base — na prática o cabelo acompanha a orelha, o que é aceitável.
Amplitude grande de rotação vai denunciar a aresta reta.

### Falta recortar (não depende de arte nova)
- íris, para o olhar pros lados
- braço direito, destacado do tronco, para o gatilho do mood 3
- cauda em base + ponta, para o chicote de verdade (hoje é fingido com
  dois giros; ver "Rig" mais abaixo)

### Já recortado: as pálpebras

`olho_esq_fechado.png` e `olho_dir_fechado.png` são **gerados da própria
`cabeca.png`**, não desenhados. O vão do olho vira pálpebra — pelo de
cima em degradê para a pele de baixo — e por cima vai a linha de cílios
traçada na pálpebra inferior real. Ficam com opacidade 0 fora da
piscada.

Duas armadilhas, caso precisem ser refeitos:

- **o contorno do olho não é um laço fechado.** Ele abre nos dois cantos
  e se funde com o pelo, então inundar buraco não fecha nada. O vão sai
  do casco: span por linha cruzado com span por coluna, que numa amêndoa
  dá a amêndoa;
- **espelhar o pelo coluna a coluna** copia a textura listrada da testa,
  e o olho fechado sai riscado de alto a baixo. A cor de origem tem que
  ser a média de algumas linhas, suavizada na horizontal — pálpebra é
  lisa mesmo.

### Rig — pronto

`rive/tasky_v2/scene.rml` existe e é o que o app empacota, em
`assets/mascote/tasky_v2.riv`. Substituiu `rive/tasky_scene/`, que
estava cortado em escala ~1/3 (cabeça 184x187 contra 405x459) e saía
borrado no diorama.

O artboard tem exatamente a moldura da arte, 1024x1536, e cada peça fica
na coordenada que `pecas.json` registra. Não há fator de escala para
errar, e o `Fit.contain` do app enquadra o rig igual à arte parada que
ele substitui — por isso `alturaMascotePadrao` e `linhaDoChaoPadrao`
continuaram valendo sem reajuste.

O que ele anima hoje:

| camada | o que faz |
|---|---|
| `Respirar` | tronco subindo e descendo (3 s em loop), cabeça acompanhando, orelhas fora de compasso uma com a outra, cauda balançando |
| `Piscar` | 5 s em loop, duas piscadas em tempos diferentes, fora do compasso da respiração |
| `Reagir` | gatilho `tap`: agacha, pula, estica no ar, amortece, e a cauda dá um tranco |
| bind `mood` | postura: altura do quadril, inclinação do tronco, inclinação da cabeça e ângulo da cauda |

**O humor aparece só na POSTURA.** As peças recortadas são as do corpo
base (mood 2), então não há semblante por mood no rig — é o item 1 de "O
QUE FALTA CRIAR" que destrava isso. Enquanto não houver, a arte parada
ainda é o único lugar onde os cinco moods têm corpo e rosto próprios;
`mascoteParado`, em `lib/widgets/cenario_tasky.dart`, troca entre os
dois caminhos numa linha.

O arco da cauda é feito com uma peça só: `cauda-base` gira pela raiz e
`cauda-ponta` gira de novo pelo meio do rabo, meio tempo atrasada. O
segundo giro também desloca a raiz, mas a raiz fica atrás do quadril e
não aparece — o que se vê é a ponta atrasando. Com a cauda recortada em
base + ponta o arco fica de verdade.

import 'dart:async';

import 'package:flutter/material.dart';

/// Tela de Recursos Terapêuticos do Bem-te-ver.
///
/// Reúne três abas de apoio ao psicólogo durante a sessão:
/// 1. Ansiedade: exercício de respiração guiada.
/// 2. Questionário: rastreio rápido do nível de depressão (PHQ-9).
/// 3. Sinais & Sintomas: resumo consultivo de transtornos mentais.
class RecursosScreen extends StatelessWidget {
  const RecursosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Ansiedade'),
              Tab(text: 'Questionário'),
              Tab(text: 'Sinais & Sintomas'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _AbaAnsiedade(),
                _AbaQuestionario(),
                _AbaSinaisSintomas(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Aba 1 - Ansiedade (exercício de respiração guiada)
// ---------------------------------------------------------------------------

class _TecnicaRespiracao {
  final String titulo;
  final int inspire;
  final int segure;
  final int expire;
  final int pausa;
  final String descricao;

  const _TecnicaRespiracao({
    required this.titulo,
    required this.inspire,
    required this.segure,
    required this.expire,
    required this.pausa,
    required this.descricao,
  });
}

class _AbaAnsiedade extends StatefulWidget {
  const _AbaAnsiedade();

  @override
  State<_AbaAnsiedade> createState() => _AbaAnsiedadeState();
}

class _AbaAnsiedadeState extends State<_AbaAnsiedade> {
  static const List<_TecnicaRespiracao> _tecnicas = [
    _TecnicaRespiracao(
      titulo: 'Box (4-4-4-4)',
      inspire: 4,
      segure: 4,
      expire: 4,
      pausa: 4,
      descricao:
          'Ritmo equilibrado que ajuda a desacelerar o sistema nervoso '
          'e a recuperar o foco em momentos de tensão.',
    ),
    _TecnicaRespiracao(
      titulo: '4-7-8',
      inspire: 4,
      segure: 7,
      expire: 8,
      pausa: 0,
      descricao:
          'Expiração longa que reduz os batimentos cardíacos. '
          'Útil em crises de ansiedade e antes de dormir.',
    ),
    _TecnicaRespiracao(
      titulo: 'Calmante (4-6)',
      inspire: 4,
      segure: 0,
      expire: 6,
      pausa: 0,
      descricao:
          'Respiração simples com expiração prolongada, '
          'indicada para acalmar rapidamente durante o atendimento.',
    ),
  ];

  int _tecnicaSelecionada = 0;

  bool _executando = false;
  String _fase = 'Pronto';
  int _segundosRestantes = _tecnicas.first.inspire;
  int _ciclos = 0;

  Timer? _timer;

  _TecnicaRespiracao get _tecnica => _tecnicas[_tecnicaSelecionada];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Avança para a próxima fase da técnica, ignorando fases com duração zero.
  void _avancarFase() {
    switch (_fase) {
      case 'Inspire':
        if (_tecnica.segure > 0) {
          _fase = 'Segure';
          _segundosRestantes = _tecnica.segure;
        } else {
          _fase = 'Expire';
          _segundosRestantes = _tecnica.expire;
        }
      case 'Segure':
        _fase = 'Expire';
        _segundosRestantes = _tecnica.expire;
      case 'Expire':
        if (_tecnica.pausa > 0) {
          _fase = 'Pausa';
          _segundosRestantes = _tecnica.pausa;
        } else {
          _ciclos++;
          _fase = 'Inspire';
          _segundosRestantes = _tecnica.inspire;
        }
      case 'Pausa':
        _ciclos++;
        _fase = 'Inspire';
        _segundosRestantes = _tecnica.inspire;
      default:
        _fase = 'Inspire';
        _segundosRestantes = _tecnica.inspire;
    }
  }

  void _iniciarTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        if (_segundosRestantes > 1) {
          _segundosRestantes -= 1;
        } else {
          _avancarFase();
        }
      });
    });
  }

  void _alternarExecucao() {
    if (_executando) {
      _timer?.cancel();
      setState(() {
        _executando = false;
      });
      return;
    }

    setState(() {
      _executando = true;

      if (_fase == 'Pronto') {
        _fase = 'Inspire';
        _segundosRestantes = _tecnica.inspire;
      }
    });

    _iniciarTimer();
  }

  void _reiniciarExercicio() {
    _timer?.cancel();
    setState(() {
      _executando = false;
      _fase = 'Pronto';
      _segundosRestantes = _tecnica.inspire;
      _ciclos = 0;
    });
  }

  void _selecionarTecnica(int indice) {
    _timer?.cancel();
    setState(() {
      _tecnicaSelecionada = indice;
      _executando = false;
      _fase = 'Pronto';
      _segundosRestantes = _tecnicas[indice].inspire;
      _ciclos = 0;
    });
  }

  // Escala visual do círculo conforme a fase de respiração.
  double get _escala {
    switch (_fase) {
      case 'Inspire':
      case 'Segure':
        return 1;
      case 'Expire':
      case 'Pausa':
        return 0.5;
      default:
        return 0.65;
    }
  }

  int get _duracaoAnimacao {
    switch (_fase) {
      case 'Inspire':
        return _tecnica.inspire * 1000;
      case 'Expire':
        return _tecnica.expire * 1000;
      default:
        return 400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Respiração guiada', style: tema.textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text(
          'Exercício prático para crises de ansiedade. '
          'Escolha a técnica, acompanhe o círculo e o contador.',
        ),
        const SizedBox(height: 20),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_tecnicas.length, (indice) {
              return Padding(
                padding: EdgeInsets.only(right: indice == _tecnicas.length - 1 ? 0 : 8),
                child: ChoiceChip(
                  key: Key('tecnica_$indice'),
                  label: Text(_tecnicas[indice].titulo),
                  selected: _tecnicaSelecionada == indice,
                  onSelected: (_) => _selecionarTecnica(indice),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          _tecnica.descricao,
          style: tema.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 260,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: _duracaoAnimacao),
                  curve: Curves.easeInOut,
                  width: 230 * _escala,
                  height: 230 * _escala,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tema.colorScheme.primaryContainer,
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: _duracaoAnimacao),
                  curve: Curves.easeInOut,
                  width: 180 * _escala,
                  height: 180 * _escala,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tema.colorScheme.primary,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _executando ? _fase : 'Começar',
                        style: tema.textTheme.titleLarge?.copyWith(
                          color: tema.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_executando)
                        Text(
                          '${_segundosRestantes}s',
                          style: tema.textTheme.headlineSmall?.copyWith(
                            color: tema.colorScheme.onPrimary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          _executando
              ? 'Ciclos realizados: $_ciclos'
              : 'Encontre uma postura confortável e relaxe os ombros.',
          textAlign: TextAlign.center,
          style: tema.textTheme.bodyMedium,
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('btn_reiniciar_respiracao'),
                onPressed: _reiniciarExercicio,
                icon: const Icon(Icons.refresh),
                label: const Text('Reiniciar'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                key: const Key('btn_toggle_respiracao'),
                onPressed: _alternarExecucao,
                icon: Icon(_executando ? Icons.pause : Icons.play_arrow),
                label: Text(_executando ? 'Pausar' : 'Iniciar'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Como aplicar na sessão',
                  style: tema.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Você pode conduzir o exercício junto com o paciente nos '
                  'primeiros minutos do atendimento ou orientá-lo a repetir '
                  'de 3 a 5 ciclos em casa, nos momentos de maior tensão.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Aba 2 - Questionário (rastreio de depressão - PHQ-9)
// ---------------------------------------------------------------------------

class _OpcaoEscala {
  final String rotulo;
  final int valor;

  const _OpcaoEscala(this.rotulo, this.valor);
}

class _ResultadoPHQ9 {
  final String nivel;
  final String orientacao;

  const _ResultadoPHQ9(this.nivel, this.orientacao);
}

class _AbaQuestionario extends StatefulWidget {
  const _AbaQuestionario();

  @override
  State<_AbaQuestionario> createState() => _AbaQuestionarioState();
}

class _AbaQuestionarioState extends State<_AbaQuestionario> {
  static const List<String> _perguntas = [
    'Pouco interesse ou prazer em fazer as coisas?',
    'Sentir-se para baixo, deprimido(a) ou sem perspectiva?',
    'Dificuldade para dormir, acordar no meio da noite ou dormir demais?',
    'Sentir-se cansado(a) ou com pouca energia?',
    'Falta de apetite ou comer em excesso?',
    'Sentir-se mal consigo mesmo(a), como um fracasso ou decepção?',
    'Dificuldade de concentração (ler, assistir TV, trabalhar)?',
    'Mover-se ou falar devagar, ou o oposto: muito agitado(a)?',
    'Pensamentos de que seria melhor estar morto(a) ou de se ferir?',
  ];

  static const List<_OpcaoEscala> _opcoes = [
    _OpcaoEscala('Nenhum dia', 0),
    _OpcaoEscala('Vários dias', 1),
    _OpcaoEscala('Mais da metade dos dias', 2),
    _OpcaoEscala('Quase todos os dias', 3),
  ];

  // Cada resposta começa em "Nenhum dia" (0).
  final List<int> _respostas = List<int>.filled(_perguntas.length, 0);

  int get _total => _respostas.fold(0, (soma, valor) => soma + valor);

  _ResultadoPHQ9 _avaliar(int total) {
    if (total <= 4) {
      return const _ResultadoPHQ9(
        'Mínima ou ausente',
        'Sintomas mínimos. Manter acompanhamento de rotina e medidas '
            'preventivas de saúde mental.',
      );
    }

    if (total <= 9) {
      return const _ResultadoPHQ9(
        'Leve',
        'Sintomas leves. Psicoeducação, técnicas de relaxamento e '
            'monitoramento quinzenal costumam ser úteis.',
      );
    }

    if (total <= 14) {
      return const _ResultadoPHQ9(
        'Moderada',
        'Sintomas moderados. Indicada intervenção psicoterápica estruturada '
            'e avaliação multidisciplinar.',
      );
    }

    if (total <= 19) {
      return const _ResultadoPHQ9(
        'Moderadamente grave',
        'Sintomas importantes. Considerar avaliação médica e '
            'acompanhamento intensificado.',
      );
    }

    return const _ResultadoPHQ9(
      'Grave',
      'Sintomas graves. Prioridade clínica: articular com a rede pública '
          '(CAPS/UBS) e avaliar risco de forma cuidadosa.',
    );
  }

  void _reiniciar() {
    setState(() {
      for (var i = 0; i < _respostas.length; i++) {
        _respostas[i] = 0;
      }
    });
  }

  Widget _opcao(int indicePergunta, _OpcaoEscala opcao) {
    final tema = Theme.of(context);
    final selecionado = _respostas[indicePergunta] == opcao.valor;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        setState(() {
          _respostas[indicePergunta] = opcao.valor;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Icon(
              selecionado
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: selecionado
                  ? tema.colorScheme.primary
                  : tema.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${opcao.rotulo} (${opcao.valor} pt)',
                style: TextStyle(
                  color: selecionado
                      ? tema.colorScheme.primary
                      : tema.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final total = _total;
    final resultado = _avaliar(total);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Nível de depressão', style: tema.textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text(
          'Nas últimas 2 semanas, com que frequência o(a) paciente foi '
          'incomodado(a) por cada situação abaixo?',
        ),
        const SizedBox(height: 20),

        ...List.generate(_perguntas.length, (indice) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${indice + 1}. ${_perguntas[indice]}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ..._opcoes.map((opcao) => _opcao(indice, opcao)),
                ],
              ),
            ),
          );
        }),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pontuação total: $total / 27',
                        style: tema.textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      resultado.nivel,
                      style: TextStyle(
                        color: tema.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  resultado.orientacao,
                  style: tema.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        OutlinedButton.icon(
          key: const Key('btn_reiniciar_questionario'),
          onPressed: _reiniciar,
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reiniciar questionário'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Instrumento de apoio (PHQ-9). O resultado é orientativo e não '
          'substitui a avaliação clínica do profissional.',
          style: tema.textTheme.bodySmall,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Aba 3 - Sinais & Sintomas (resumo consultivo)
// ---------------------------------------------------------------------------

class _Transtorno {
  final String nome;
  final String resumo;
  final List<String> sinais;

  const _Transtorno({
    required this.nome,
    required this.resumo,
    required this.sinais,
  });
}

class _AbaSinaisSintomas extends StatelessWidget {
  const _AbaSinaisSintomas();

  static const List<_Transtorno> _transtornos = [
    _Transtorno(
      nome: 'Depressão',
      resumo:
          'Humor deprimido e/ou perda de interesse persistentes por pelo '
          'menos 2 semanas, com prejuízo no dia a dia.',
      sinais: [
        'Tristeza, vazio ou irritabilidade na maior parte do dia',
        'Perda de interesse ou prazer (anedonia)',
        'Alterações de sono e de apetite',
        'Cansaço, falta de energia e lentidão',
        'Dificuldade de concentração e de decidir',
        'Culpa, inutilidade ou desesperança',
        'Pensamentos de morte ou de se ferir',
      ],
    ),
    _Transtorno(
      nome: 'Ansiedade Generalizada (TAG)',
      resumo:
          'Preocupação excessiva e difícil de controlar na maioria dos dias, '
          'por 6 meses ou mais.',
      sinais: [
        'Preocupação constante com vários assuntos',
        'Inquietação ou sensação de estar "no limite"',
        'Tensão muscular e dores difusas',
        'Dificuldade para relaxar e se concentrar',
        'Irritabilidade e alterações do sono',
        'Sintomas físicos: taquicardia, suor, tremores',
      ],
    ),
    _Transtorno(
      nome: 'Transtorno de Pânico',
      resumo:
          'Crises súbitas e intensas de medo, com pico em poucos minutos, '
          'seguidas de preocupação persistente com novas crises.',
      sinais: [
        'Palpitações, falta de ar ou sufocamento',
        'Dor no peito e tontura',
        'Medo de morrer ou de "enlouquecer"',
        'Formigamentos e calafrios',
        'Evitação de locais ligados às crises',
      ],
    ),
    _Transtorno(
      nome: 'Transtorno Bipolar',
      resumo:
          'Alternância entre episódios depressivos e de mania/hipomania, '
          'com mudanças claras de energia e comportamento.',
      sinais: [
        'Fases de euforia, energia e fala acelerada',
        'Redução da necessidade de sono',
        'Gastos impulsivos e decisões arriscadas',
        'Irritabilidade e agitação',
        'Alternância com períodos de depressão',
      ],
    ),
    _Transtorno(
      nome: 'Transtorno Obsessivo-Compulsivo (TOC)',
      resumo:
          'Obsessões (pensamentos intrusivos) e/ou compulsões (rituais) que '
          'consomem tempo e causam sofrimento.',
      sinais: [
        'Pensamentos repetitivos e indesejados',
        'Medo de contaminação, erro ou desordem',
        'Rituais de verificação, limpeza ou contagem',
        'Necessidade intensa de simetria e ordem',
        'Alívio momentâneo ao executar o ritual',
      ],
    ),
    _Transtorno(
      nome: 'Estresse Pós-Traumático (TEPT)',
      resumo:
          'Após um evento traumático, surgem sintomas persistentes por mais '
          'de 1 mês.',
      sinais: [
        'Lembranças intrusivas ou flashbacks',
        'Pesadelos recorrentes',
        'Evitação de lembranças, pessoas e locais',
        'Hipervigilância e sobressalto fácil',
        'Dificuldade de sono e irritabilidade',
      ],
    ),
    _Transtorno(
      nome: 'TDAH (em adultos)',
      resumo:
          'Padrão persistente de desatenção e/ou hiperatividade-impulsividade '
          'presente desde a infância, com prejuízo funcional.',
      sinais: [
        'Dificuldade de manter a atenção',
        'Esquecimentos e desorganização',
        'Procrastinação e tarefas inacabadas',
        'Inquietação e impulsividade',
        'Instabilidade de humor',
      ],
    ),
    _Transtorno(
      nome: 'Transtornos Psicóticos',
      resumo:
          'Alterações de percepção e de pensamento, em geral com queda '
          'importante do funcionamento social e laboral.',
      sinais: [
        'Delírios (crenças fixas que não correspondem à realidade)',
        'Alucinações, geralmente auditivas',
        'Discurso desorganizado',
        'Embotamento afetivo e isolamento',
        'Queda no desempenho escolar ou profissional',
      ],
    ),
    _Transtorno(
      nome: 'Transtornos Alimentares',
      resumo:
          'Relação disfuncional com alimentação, peso e imagem corporal '
          '(anorexia, bulimia, compulsão alimentar).',
      sinais: [
        'Preocupação excessiva com peso e forma do corpo',
        'Restrição alimentar severa',
        'Episódios de compulsão seguidos de culpa',
        'Vômitos ou uso de laxantes/diuréticos',
        'Isolamento nas refeições e alterações de peso',
      ],
    ),
    _Transtorno(
      nome: 'Uso de Substâncias',
      resumo:
          'Uso problemático de álcool ou outras drogas, com prejuízo na '
          'saúde, nas relações e no trabalho.',
      sinais: [
        'Necessidade de aumentar a dose (tolerância)',
        'Sintomas de abstinência ao parar',
        'Abandono de atividades antes prazerosas',
        'Uso mesmo com prejuízo evidente',
        'Esconder o consumo e problemas familiares ou legais',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Sinais & sintomas', style: tema.textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text(
          'Resumo de apoio para consulta rápida durante a sessão. '
          'Toque em cada condição para ver os sinais mais comuns.',
        ),

        const SizedBox(height: 20),

        // Sinais de alerta que exigem atenção imediata.
        Card(
          color: tema.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: tema.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sinais de alerta',
                      style: tema.textTheme.titleSmall?.copyWith(
                        color: tema.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Priorize avaliação imediata e acione a rede de apoio '
                  '(CAPS/UBS ou emergência) diante de:',
                  style: TextStyle(color: tema.colorScheme.onErrorContainer),
                ),
                const SizedBox(height: 8),
                ...[
                  'Ideias, planos ou tentativas de se matar ou se ferir',
                  'Autoagressão (cortes, queimaduras)',
                  'Desorganização grave, com perda de contato com a realidade',
                  'Agressividade que coloca terceiros em risco',
                  'Incapacidade de autocuidado ou recusa de água e alimento',
                ].map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '•  ',
                          style: TextStyle(
                            color: tema.colorScheme.onErrorContainer,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              color: tema.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Condições frequentes',
          style: tema.textTheme.titleMedium,
        ),

        const SizedBox(height: 8),

        ..._transtornos.map((transtorno) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Text(
                transtorno.nome,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(transtorno.resumo),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: transtorno.sinais.map((sinal) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: tema.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(sinal)),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }),

        const SizedBox(height: 8),

        Text(
          'Material educativo de apoio ao profissional. Não substitui a '
          'avaliação clínica, o uso de instrumentos validados nem o '
          'julgamento do psicólogo.',
          style: tema.textTheme.bodySmall,
        ),
      ],
    );
  }
}

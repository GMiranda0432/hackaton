import 'dart:async';

import 'package:flutter/material.dart';

// ============================================================
// BEM-TE-VER — RECURSOS TERAPÊUTICOS
// ============================================================

class RecursosScreen extends StatelessWidget {
  const RecursosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
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

// ============================================================
// ABA 1 — ANSIEDADE
// ============================================================

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
  static const _tecnicas = [
    _TecnicaRespiracao(
      titulo: 'Box (4-4-4-4)',
      inspire: 4,
      segure: 4,
      expire: 4,
      pausa: 4,
      descricao:
          'Respiração em quatro etapas, com tempos iguais '
          'de inspiração, retenção, expiração e pausa.',
    ),
    _TecnicaRespiracao(
      titulo: '4-7-8',
      inspire: 4,
      segure: 7,
      expire: 8,
      pausa: 0,
      descricao:
          'Técnica com expiração prolongada. '
          'Deve ser utilizada conforme a tolerância individual.',
    ),
    _TecnicaRespiracao(
      titulo: 'Calmante (4-6)',
      inspire: 4,
      segure: 0,
      expire: 6,
      pausa: 0,
      descricao:
          'Inspiração de quatro segundos seguida de '
          'expiração lenta de seis segundos.',
    ),
  ];

  int _tecnicaSelecionada = 0;
  bool _executando = false;
  String _fase = 'Pronto';
  int _segundosRestantes = 4;
  int _ciclos = 0;

  Timer? _timer;

  _TecnicaRespiracao get _tecnica => _tecnicas[_tecnicaSelecionada];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
        break;

      case 'Segure':
        _fase = 'Expire';
        _segundosRestantes = _tecnica.expire;
        break;

      case 'Expire':
        if (_tecnica.pausa > 0) {
          _fase = 'Pausa';
          _segundosRestantes = _tecnica.pausa;
        } else {
          _ciclos++;
          _fase = 'Inspire';
          _segundosRestantes = _tecnica.inspire;
        }
        break;

      case 'Pausa':
        _ciclos++;
        _fase = 'Inspire';
        _segundosRestantes = _tecnica.inspire;
        break;

      default:
        _fase = 'Inspire';
        _segundosRestantes = _tecnica.inspire;
    }
  }

  void _iniciarTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        if (_segundosRestantes > 1) {
          _segundosRestantes--;
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
          'Escolha uma técnica e acompanhe as instruções '
          'de respiração na tela.',
        ),
        const SizedBox(height: 20),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_tecnicas.length, (indice) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
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
          textAlign: TextAlign.center,
          style: tema.textTheme.bodySmall,
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
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tema.colorScheme.primary,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _fase == 'Pronto' ? 'Começar' : _fase,
                        style: tema.textTheme.titleLarge?.copyWith(
                          color: tema.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (_fase != 'Pronto')
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

        Text('Ciclos realizados: $_ciclos', textAlign: TextAlign.center),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('btn_reiniciar_respiracao'),
                onPressed: _reiniciarExercicio,
                icon: const Icon(Icons.refresh),
                label: const Text('Reiniciar'),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: FilledButton.icon(
                key: const Key('btn_toggle_respiracao'),
                onPressed: _alternarExecucao,
                icon: Icon(_executando ? Icons.pause : Icons.play_arrow),
                label: Text(_executando ? 'Pausar' : 'Iniciar'),
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
                  'O profissional pode orientar o exercício '
                  'conforme as necessidades e condições do paciente. '
                  'Interrompa caso haja tontura, falta de ar ou desconforto.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ABA 2 — QUESTIONÁRIO PHQ-9
// ============================================================

class _OpcaoEscala {
  final String rotulo;
  final int valor;

  const _OpcaoEscala(this.rotulo, this.valor);
}

class _ResultadoPHQ9 {
  final String nivel;

  const _ResultadoPHQ9(this.nivel);
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

  // Nenhuma pergunta começa respondida.
  final List<int?> _respostas = List<int?>.filled(_perguntas.length, null);

  int get _quantidadeRespondida =>
      _respostas.where((resposta) => resposta != null).length;

  bool get _completo => _quantidadeRespondida == _perguntas.length;

  int get _total =>
      _respostas.fold<int>(0, (soma, resposta) => soma + (resposta ?? 0));

  // Alerta específico para a pergunta 9.
  bool get _alertaAutoagressao => (_respostas[8] ?? 0) > 0;

  _ResultadoPHQ9 _avaliar(int total) {
    if (total <= 4) {
      return const _ResultadoPHQ9('Mínima ou ausente');
    }

    if (total <= 9) {
      return const _ResultadoPHQ9('Leve');
    }

    if (total <= 14) {
      return const _ResultadoPHQ9('Moderada');
    }

    if (total <= 19) {
      return const _ResultadoPHQ9('Moderadamente grave');
    }

    return const _ResultadoPHQ9('Grave');
  }

  void _reiniciar() {
    setState(() {
      for (var i = 0; i < _respostas.length; i++) {
        _respostas[i] = null;
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Questionário PHQ-9', style: tema.textTheme.headlineSmall),

        const SizedBox(height: 8),

        const Text(
          'Nas últimas duas semanas, com que frequência '
          'o(a) paciente foi incomodado(a) por cada situação?',
        ),

        const SizedBox(height: 16),

        // Mostra o progresso sem apresentar pontuação prematura.
        Text(
          'Perguntas respondidas: '
          '$_quantidadeRespondida de ${_perguntas.length}',
          style: tema.textTheme.titleSmall,
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

        // Alerta mesmo se o questionário estiver incompleto.
        if (_alertaAutoagressao) ...[
          const SizedBox(height: 12),

          Card(
            key: const Key('alerta_autoagressao'),
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

                      Expanded(
                        child: Text(
                          'Atenção: resposta positiva à pergunta 9',
                          style: tema.textTheme.titleSmall?.copyWith(
                            color: tema.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'A resposta indica a necessidade de '
                    'avaliação clínica específica sobre '
                    'pensamentos de morte ou autoagressão, '
                    'independentemente da pontuação total. '
                    'O profissional deve investigar o risco '
                    'atual e adotar as medidas de segurança '
                    'adequadas. Havendo risco iminente, '
                    'acionar atendimento de emergência.',
                    style: TextStyle(color: tema.colorScheme.onErrorContainer),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // O resultado aparece somente com as nove respostas.
        Card(
          key: const Key('resultado_phq9'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_completo) ...[
                  Text(
                    'Questionário incompleto',
                    style: tema.textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Responda as ${_perguntas.length} '
                    'perguntas para visualizar a '
                    'pontuação e a classificação.',
                  ),
                ] else ...[
                  Text(
                    'Pontuação total: $_total / 27',
                    style: tema.textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Intensidade dos sintomas: '
                    '${_avaliar(_total).nivel}',
                    style: TextStyle(
                      color: tema.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'A pontuação representa uma medida '
                    'de intensidade dos sintomas relatados. '
                    'Não estabelece diagnóstico por si só.',
                  ),
                ],
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
          'Instrumento de rastreamento de sintomas '
          'depressivos. Não substitui avaliação clínica, '
          'entrevista profissional ou investigação '
          'específica de risco.',
          style: tema.textTheme.bodySmall,
        ),
      ],
    );
  }
}

// ============================================================
// ABA 3 — SINAIS E SINTOMAS
// ============================================================

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
          'Humor deprimido e/ou perda persistente de '
          'interesse, com possível prejuízo funcional.',
      sinais: [
        'Tristeza ou irritabilidade persistente',
        'Perda de interesse ou prazer',
        'Alterações no sono e no apetite',
        'Cansaço e falta de energia',
        'Dificuldade de concentração',
        'Culpa ou desesperança',
        'Pensamentos de morte ou autoagressão',
      ],
    ),

    _Transtorno(
      nome: 'Ansiedade Generalizada (TAG)',
      resumo:
          'Preocupação excessiva e difícil de controlar '
          'sobre diferentes situações do cotidiano.',
      sinais: [
        'Preocupação constante',
        'Inquietação e tensão muscular',
        'Dificuldade para relaxar',
        'Irritabilidade',
        'Alterações do sono',
        'Dificuldade de concentração',
      ],
    ),

    _Transtorno(
      nome: 'Transtorno de Pânico',
      resumo:
          'Ataques de pânico recorrentes, acompanhados '
          'de preocupação ou mudanças comportamentais.',
      sinais: [
        'Palpitações',
        'Sensação de falta de ar',
        'Tontura e tremores',
        'Medo intenso de morrer',
        'Medo de novas crises',
        'Evitação de situações associadas aos ataques',
      ],
    ),

    _Transtorno(
      nome: 'Transtorno Bipolar',
      resumo:
          'Alterações episódicas de humor e energia, '
          'incluindo mania ou hipomania.',
      sinais: [
        'Elevação ou irritabilidade do humor',
        'Aumento de energia',
        'Redução da necessidade de sono',
        'Fala acelerada',
        'Impulsividade',
        'Possíveis episódios depressivos',
      ],
    ),

    _Transtorno(
      nome: 'Transtorno Obsessivo-Compulsivo (TOC)',
      resumo:
          'Obsessões e/ou compulsões associadas '
          'a sofrimento ou prejuízo no cotidiano.',
      sinais: [
        'Pensamentos intrusivos e recorrentes',
        'Medo excessivo de contaminação',
        'Rituais de verificação',
        'Comportamentos repetitivos',
        'Necessidade intensa de simetria',
        'Sofrimento ao tentar resistir aos rituais',
      ],
    ),

    _Transtorno(
      nome: 'Estresse Pós-Traumático (TEPT)',
      resumo:
          'Sintomas relacionados à exposição '
          'a acontecimentos traumáticos.',
      sinais: [
        'Lembranças intrusivas',
        'Pesadelos recorrentes',
        'Evitação de lembranças do trauma',
        'Hipervigilância',
        'Alterações de humor',
        'Dificuldades com o sono',
      ],
    ),

    _Transtorno(
      nome: 'TDAH (em adultos)',
      resumo:
          'Padrão persistente de desatenção e/ou '
          'hiperatividade-impulsividade com prejuízo funcional.',
      sinais: [
        'Dificuldade de manter a atenção',
        'Esquecimentos frequentes',
        'Desorganização',
        'Dificuldade para concluir tarefas',
        'Inquietação',
        'Impulsividade',
      ],
    ),

    _Transtorno(
      nome: 'Transtornos Psicóticos',
      resumo:
          'Condições que podem envolver alterações '
          'importantes da percepção e do pensamento.',
      sinais: [
        'Delírios',
        'Alucinações',
        'Discurso desorganizado',
        'Comportamento desorganizado',
        'Isolamento social',
        'Prejuízo do funcionamento cotidiano',
      ],
    ),

    _Transtorno(
      nome: 'Transtornos Alimentares',
      resumo:
          'Alterações persistentes do comportamento '
          'alimentar e da relação com o corpo.',
      sinais: [
        'Preocupação intensa com peso e aparência',
        'Restrição alimentar',
        'Episódios de compulsão alimentar',
        'Comportamentos compensatórios',
        'Sentimentos de culpa relacionados à alimentação',
        'Alterações físicas e nutricionais',
      ],
    ),

    _Transtorno(
      nome: 'Uso de Substâncias',
      resumo:
          'Uso problemático de álcool ou outras '
          'substâncias com possíveis prejuízos.',
      sinais: [
        'Dificuldade em controlar o consumo',
        'Aumento da tolerância',
        'Sintomas de abstinência',
        'Prejuízo nas atividades diárias',
        'Persistência do uso apesar das consequências',
        'Conflitos familiares ou sociais',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Sinais e sintomas', style: tema.textTheme.headlineSmall),

        const SizedBox(height: 8),

        const Text(
          'Material de apoio para consulta rápida durante '
          'os atendimentos. Toque em uma condição para '
          'visualizar seus sinais mais comuns.',
        ),

        const SizedBox(height: 20),

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

                    Expanded(
                      child: Text(
                        'Sinais de alerta',
                        style: tema.textTheme.titleSmall?.copyWith(
                          color: tema.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'Situações que exigem avaliação '
                  'prioritária e possível encaminhamento:',
                  style: TextStyle(color: tema.colorScheme.onErrorContainer),
                ),

                const SizedBox(height: 12),

                ...[
                  'Pensamentos suicidas, planos ou tentativas',
                  'Autoagressão',
                  'Perda importante do contato com a realidade',
                  'Comportamento que coloca outras pessoas em risco',
                  'Incapacidade grave de autocuidado',
                ].map(
                  (sinal) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 7,
                          color: tema.colorScheme.onErrorContainer,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            sinal,
                            style: TextStyle(
                              color: tema.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text('Condições frequentes', style: tema.textTheme.titleMedium),

        const SizedBox(height: 8),

        ..._transtornos.map(
          (transtorno) => Card(
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
                  padding: const EdgeInsets.only(bottom: 8),
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
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Material informativo. A presença de sinais '
          'isolados não confirma diagnóstico. '
          'A avaliação deve ser realizada por '
          'profissional habilitado.',
          style: tema.textTheme.bodySmall,
        ),
      ],
    );
  }
}

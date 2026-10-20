import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../models/paciente.dart';

// ============================================================
// FORMATAÇÃO
// ============================================================

String formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');

  return '$dia/$mes/${data.year}';
}

String formatarHora(DateTime data) {
  final hora = data.hour.toString().padLeft(2, '0');
  final minuto = data.minute.toString().padLeft(2, '0');

  return '$hora:$minuto';
}

// Formata valores com separador de milhares e vírgula decimal.
String formatarValor(double valor) {
  final partes = valor.toStringAsFixed(2).split('.');
  final inteiro = partes[0];
  final centavos = partes[1];

  final formatado = StringBuffer();

  for (var i = 0; i < inteiro.length; i++) {
    if (i > 0 && (inteiro.length - i) % 3 == 0) {
      formatado.write('.');
    }

    formatado.write(inteiro[i]);
  }

  return 'R\$ ${formatado.toString()},$centavos';
}

// ============================================================
// TELA PRINCIPAL DA AGENDA
// ============================================================

class AgendaScreen extends StatelessWidget {
  final List<Paciente> pacientes;
  final List<Agendamento> agendamentos;
  final ValueChanged<Agendamento> onSalvar;
  final ValueChanged<String> onExcluir;

  const AgendaScreen({
    super.key,
    required this.pacientes,
    required this.agendamentos,
    required this.onSalvar,
    required this.onExcluir,
  });

  String _nomePaciente(String id) {
    for (final paciente in pacientes) {
      if (paciente.id == id) {
        return paciente.nome;
      }
    }

    return 'Paciente não encontrado';
  }

  // Impede consultas em horários sobrepostos.
  bool _possuiConflito(Agendamento candidato) {
    return agendamentos.any(
      (existente) =>
          existente.id != candidato.id && existente.conflitaCom(candidato),
    );
  }

  // Abre o formulário para criar ou editar uma consulta.
  Future<void> _abrirFormulario(
    BuildContext context, [
    Agendamento? existente,
  ]) async {
    if (pacientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre um paciente antes de agendar uma consulta.'),
        ),
      );
      return;
    }

    final resultado = await showModalBottomSheet<Agendamento>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return FormularioAgendamento(
          pacientes: pacientes,
          agendamento: existente,
          possuiConflito: _possuiConflito,
        );
      },
    );

    if (resultado == null || !context.mounted) {
      return;
    }

    onSalvar(resultado);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existente == null
              ? 'Consulta agendada com sucesso!'
              : 'Agendamento atualizado com sucesso!',
        ),
      ),
    );
  }

  // Solicita confirmação antes de cancelar uma consulta.
  Future<void> _confirmarExclusao(
    BuildContext context,
    Agendamento agendamento,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancelar agendamento'),
          content: Text(
            'Deseja cancelar a consulta de '
            '${_nomePaciente(agendamento.pacienteId)} '
            'em ${formatarData(agendamento.inicio)}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) {
      return;
    }

    onExcluir(agendamento.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agendamento cancelado com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordenados = [...agendamentos]
      ..sort((a, b) => a.inicio.compareTo(b.inicio));

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Minha agenda',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Chip(label: Text('${agendamentos.length}')),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              'Organize os horários e os valores '
              'dos atendimentos do consultório.',
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              key: const Key('btn_nova_consulta'),
              onPressed: () => _abrirFormulario(context),
              icon: const Icon(Icons.event_available),
              label: const Text('Nova consulta'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),

            const SizedBox(height: 24),

            if (ordenados.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 72),
                child: Column(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 64),
                    SizedBox(height: 16),
                    Text('Nenhuma consulta agendada'),
                    SizedBox(height: 8),
                    Text(
                      'Cadastre sua primeira consulta para começar.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...ordenados.map(
                (agendamento) => Card(
                  key: Key('consulta_${agendamento.id}'),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nomePaciente(agendamento.pacienteId),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            const Icon(Icons.event_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(formatarData(agendamento.inicio)),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '${formatarHora(agendamento.inicio)} '
                              'às ${formatarHora(agendamento.fim)}',
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Valor por hora: '
                          '${formatarValor(agendamento.valorHora)}',
                        ),

                        Text(
                          'Valor total: '
                          '${formatarValor(agendamento.valorTotal)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                _abrirFormulario(context, agendamento);
                              },
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Editar'),
                            ),

                            TextButton.icon(
                              onPressed: () {
                                _confirmarExclusao(context, agendamento);
                              },
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Cancelar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FORMULÁRIO DE AGENDAMENTO
// ============================================================

class FormularioAgendamento extends StatefulWidget {
  final List<Paciente> pacientes;
  final Agendamento? agendamento;
  final bool Function(Agendamento) possuiConflito;

  const FormularioAgendamento({
    super.key,
    required this.pacientes,
    required this.possuiConflito,
    this.agendamento,
  });

  @override
  State<FormularioAgendamento> createState() => _FormularioAgendamentoState();
}

class _FormularioAgendamentoState extends State<FormularioAgendamento> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();

  // Limite definido para a demonstração do protótipo.
  static const double _valorHoraMaximo = 10000;

  late String _pacienteId;
  late DateTime _data;
  late TimeOfDay _inicio;
  late TimeOfDay _fim;

  String? _erroHorario;

  @override
  void initState() {
    super.initState();

    final atual = widget.agendamento;
    final agora = DateTime.now();

    _pacienteId = atual?.pacienteId ?? widget.pacientes.first.id;

    // Novas consultas começam em uma data válida.
    final horarioPadrao = DateTime(agora.year, agora.month, agora.day, 9);

    _data =
        atual?.inicio ??
        (horarioPadrao.isAfter(agora)
            ? agora
            : DateTime(agora.year, agora.month, agora.day + 1));

    _inicio = atual != null
        ? TimeOfDay.fromDateTime(atual.inicio)
        : const TimeOfDay(hour: 9, minute: 0);

    _fim = atual != null
        ? TimeOfDay.fromDateTime(atual.fim)
        : const TimeOfDay(hour: 10, minute: 0);

    _valorController.text = (atual?.valorHora ?? 100)
        .toStringAsFixed(2)
        .replaceAll('.', ',');
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  int _minutos(TimeOfDay horario) {
    return horario.hour * 60 + horario.minute;
  }

  // Aceita valores como 100, 100,50 ou 100.50.
  // Não permite valores negativos ou acima de R$ 10.000/h.
  double? get _valorHora {
    final texto = _valorController.text.trim();

    final formatoValido = RegExp(r'^\d{1,5}([,.]\d{1,2})?$').hasMatch(texto);

    if (!formatoValido) {
      return null;
    }

    final valor = double.tryParse(texto.replaceAll(',', '.'));

    if (valor == null ||
        !valor.isFinite ||
        valor < 0 ||
        valor > _valorHoraMaximo) {
      return null;
    }

    return valor;
  }

  double get _valorTotal {
    final valor = _valorHora;
    final minutos = _minutos(_fim) - _minutos(_inicio);

    if (valor == null || minutos <= 0) {
      return 0;
    }

    return minutos / 60 * valor;
  }

  // Abre o calendário.
  Future<void> _selecionarData() async {
    final agora = DateTime.now();

    final primeiroDia = widget.agendamento == null
        ? DateTime(agora.year, agora.month, agora.day)
        : DateTime(2020);

    final data = await showDatePicker(
      context: context,
      initialDate: _data.isBefore(primeiroDia) ? primeiroDia : _data,
      firstDate: primeiroDia,
      lastDate: DateTime(2100),
    );

    if (data != null && mounted) {
      setState(() {
        _data = data;
        _erroHorario = null;
      });
    }
  }

  // Abre o seletor de horário no formato de 24 horas.
  Future<void> _selecionarHorario({required bool horarioInicial}) async {
    final selecionado = await showTimePicker(
      context: context,
      initialTime: horarioInicial ? _inicio : _fim,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selecionado != null && mounted) {
      setState(() {
        if (horarioInicial) {
          _inicio = selecionado;
        } else {
          _fim = selecionado;
        }

        _erroHorario = null;
      });
    }
  }

  DateTime _combinarDataHorario(TimeOfDay horario) {
    return DateTime(
      _data.year,
      _data.month,
      _data.day,
      horario.hour,
      horario.minute,
    );
  }

  String _formatarTimeOfDay(TimeOfDay horario) {
    final horas = horario.hour.toString().padLeft(2, '0');
    final minutos = horario.minute.toString().padLeft(2, '0');

    return '$horas:$minutos';
  }

  // Valida e salva o agendamento.
  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final inicio = _combinarDataHorario(_inicio);
    final fim = _combinarDataHorario(_fim);

    // Horário final precisa ser posterior ao inicial.
    if (!fim.isAfter(inicio)) {
      setState(() {
        _erroHorario = 'O horário final deve ser posterior ao inicial.';
      });
      return;
    }

    // Impede criar consultas no passado.
    // Consultas antigas podem manter sua data durante
    // a edição, desde que o horário não seja alterado.
    final horarioOriginal = widget.agendamento?.inicio;

    final horarioFoiAlterado =
        horarioOriginal == null || !inicio.isAtSameMomentAs(horarioOriginal);

    if (horarioFoiAlterado && inicio.isBefore(DateTime.now())) {
      setState(() {
        _erroHorario = 'Não é possível agendar consultas no passado.';
      });
      return;
    }

    final novo = Agendamento(
      id:
          widget.agendamento?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      pacienteId: _pacienteId,
      inicio: inicio,
      fim: fim,
      valorHora: _valorHora!,
    );

    // Confere se já existe uma consulta nesse horário.
    if (widget.possuiConflito(novo)) {
      setState(() {
        _erroHorario = 'Já existe uma consulta nesse intervalo de horário.';
      });
      return;
    }

    Navigator.pop(context, novo);
  }

  @override
  Widget build(BuildContext context) {
    final valorValido = _valorHora != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.agendamento == null
                    ? 'Agendar consulta'
                    : 'Editar agendamento',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 20),

              // Seleção do paciente.
              DropdownButtonFormField<String>(
                key: const Key('campo_agenda_paciente'),
                initialValue: _pacienteId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Paciente',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: widget.pacientes.map((paciente) {
                  return DropdownMenuItem(
                    value: paciente.id,
                    child: Text(paciente.nome, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (id) {
                  if (id != null) {
                    setState(() {
                      _pacienteId = id;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Data da consulta.
              OutlinedButton.icon(
                key: const Key('btn_agenda_data'),
                onPressed: _selecionarData,
                icon: const Icon(Icons.calendar_today),
                label: Text('Data: ${formatarData(_data)}'),
              ),

              const SizedBox(height: 12),

              // Horário de início e término.
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('btn_agenda_inicio'),
                      onPressed: () {
                        _selecionarHorario(horarioInicial: true);
                      },
                      child: Text('Início: ${_formatarTimeOfDay(_inicio)}'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton(
                      key: const Key('btn_agenda_fim'),
                      onPressed: () {
                        _selecionarHorario(horarioInicial: false);
                      },
                      child: Text('Fim: ${_formatarTimeOfDay(_fim)}'),
                    ),
                  ),
                ],
              ),

              // Mensagens de erro relacionadas a horários.
              if (_erroHorario != null) ...[
                const SizedBox(height: 12),
                Text(
                  _erroHorario!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],

              const SizedBox(height: 16),

              // Valor cobrado por hora.
              TextFormField(
                key: const Key('campo_agenda_valor'),
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: 'Valor por hora (R\$)',
                  hintText: 'Ex.: 150,00',
                  helperText: 'Valor permitido: R\$ 0,00 a R\$ 10.000,00',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                onChanged: (_) {
                  setState(() {});
                },
                validator: (_) {
                  if (_valorHora == null) {
                    return 'Informe um valor entre '
                        'R\$ 0,00 e R\$ 10.000,00';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Cálculo automático do valor total.
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Valor total da consulta'),

                      const SizedBox(height: 8),

                      Text(
                        valorValido
                            ? formatarValor(_valorTotal)
                            : 'Valor inválido',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              FilledButton.icon(
                key: const Key('btn_salvar_consulta'),
                onPressed: _salvar,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Salvar consulta'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

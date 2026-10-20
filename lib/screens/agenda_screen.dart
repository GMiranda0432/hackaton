import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../models/paciente.dart';

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

String formatarValor(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}

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

  bool _possuiConflito(Agendamento candidato) {
    return agendamentos.any(
      (existente) =>
          existente.id != candidato.id && existente.conflitaCom(candidato),
    );
  }

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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
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

  late String _pacienteId;
  late DateTime _data;
  late TimeOfDay _inicio;
  late TimeOfDay _fim;

  String? _erroHorario;

  @override
  void initState() {
    super.initState();

    final atual = widget.agendamento;

    _pacienteId = atual?.pacienteId ?? widget.pacientes.first.id;
    _data = atual?.inicio ?? DateTime.now();

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

  int _minutos(TimeOfDay hora) {
    return hora.hour * 60 + hora.minute;
  }

  double? get _valorHora {
    final texto = _valorController.text.trim().replaceAll(',', '.');

    return double.tryParse(texto);
  }

  double get _valorTotal {
    final valor = _valorHora ?? 0;
    final minutos = _minutos(_fim) - _minutos(_inicio);

    if (minutos <= 0 || valor < 0 || !valor.isFinite) {
      return 0;
    }

    return minutos / 60 * valor;
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (data != null && mounted) {
      setState(() {
        _data = data;
        _erroHorario = null;
      });
    }
  }

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

  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_minutos(_fim) <= _minutos(_inicio)) {
      setState(() {
        _erroHorario = 'O horário final deve ser posterior ao inicial.';
      });
      return;
    }

    final novo = Agendamento(
      id:
          widget.agendamento?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      pacienteId: _pacienteId,
      inicio: _combinarDataHorario(_inicio),
      fim: _combinarDataHorario(_fim),
      valorHora: _valorHora!,
    );

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

              OutlinedButton.icon(
                key: const Key('btn_agenda_data'),
                onPressed: _selecionarData,
                icon: const Icon(Icons.calendar_today),
                label: Text('Data: ${formatarData(_data)}'),
              ),

              const SizedBox(height: 12),

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

              if (_erroHorario != null) ...[
                const SizedBox(height: 12),
                Text(
                  _erroHorario!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],

              const SizedBox(height: 16),

              TextFormField(
                key: const Key('campo_agenda_valor'),
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor por hora (R\$)',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                onChanged: (_) {
                  setState(() {});
                },
                validator: (valor) {
                  final preco = _valorHora;

                  if (preco == null || !preco.isFinite || preco < 0) {
                    return 'Informe um valor válido';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Valor total da consulta'),
                      const SizedBox(height: 8),
                      Text(
                        formatarValor(_valorTotal),
                        style: Theme.of(context).textTheme.headlineSmall,
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

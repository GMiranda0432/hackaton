import 'package:flutter/material.dart';

import '../models/paciente.dart';

class PacientesScreen extends StatelessWidget {
  final List<Paciente> pacientes;
  final ValueChanged<Paciente> onCadastrar;

  const PacientesScreen({
    super.key,
    required this.pacientes,
    required this.onCadastrar,
  });

  Future<void> _abrirCadastro(BuildContext context) async {
    final paciente = await showModalBottomSheet<Paciente>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return const FormularioPaciente();
      },
    );

    if (paciente == null || !context.mounted) {
      return;
    }

    onCadastrar(paciente);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paciente cadastrado com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pacientesOrdenados = [...pacientes]
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Meus pacientes',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Chip(label: Text('${pacientes.length}')),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'Organize os pacientes cadastrados '
            'em seu consultório.',
          ),

          const SizedBox(height: 20),

          FilledButton.icon(
            key: const Key('btn_novo_paciente'),
            onPressed: () => _abrirCadastro(context),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Novo paciente'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: pacientesOrdenados.isEmpty
                ? const _ListaVazia()
                : ListView.builder(
                    itemCount: pacientesOrdenados.length,
                    itemBuilder: (context, index) {
                      return _CardPaciente(paciente: pacientesOrdenados[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ListaVazia extends StatelessWidget {
  const _ListaVazia();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(height: 16),

          Text(
            'Nenhum paciente cadastrado',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 8),

          const Text(
            'Cadastre o primeiro paciente para começar.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CardPaciente extends StatelessWidget {
  final Paciente paciente;

  const _CardPaciente({required this.paciente});

  String get iniciais {
    final partes = paciente.nome.trim().split(RegExp(r'\s+'));

    return partes.take(2).map((parte) => parte[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(child: Text(iniciais)),

          title: Text(
            paciente.nome,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),

              Text('${paciente.idade} anos'),

              if (paciente.telefone.isNotEmpty) Text(paciente.telefone),

              const SizedBox(height: 6),

              Text(
                paciente.status.descricao,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FormularioPaciente extends StatefulWidget {
  const FormularioPaciente({super.key});

  @override
  State<FormularioPaciente> createState() => _FormularioPacienteState();
}

class _FormularioPacienteState extends State<FormularioPaciente> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _idadeController = TextEditingController();
  final _telefoneController = TextEditingController();

  StatusPaciente _status = StatusPaciente.emAtendimento;

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final paciente = Paciente(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nome: _nomeController.text.trim(),
      idade: int.parse(_idadeController.text.trim()),
      telefone: _telefoneController.text.trim(),
      status: _status,
    );

    Navigator.pop(context, paciente);
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
                'Cadastrar paciente',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 8),

              const Text('Preencha as informações do paciente.'),

              const SizedBox(height: 24),

              // Nome completo.
              TextFormField(
                key: const Key('campo_paciente_nome'),
                controller: _nomeController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().length < 3) {
                    return 'Informe o nome do paciente';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Idade.
              TextFormField(
                key: const Key('campo_paciente_idade'),
                controller: _idadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Idade',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                validator: (valor) {
                  final idade = int.tryParse(valor?.trim() ?? '');

                  if (idade == null || idade < 2 || idade > 100) {
                    return 'Informe uma idade válida';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Telefone.
              TextFormField(
                key: const Key('campo_paciente_telefone'),
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone (opcional)',
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: '(27) 99999-9999',
                ),
                validator: (valor) {
                  final texto = valor?.trim() ?? '';

                  if (texto.isEmpty) {
                    return null;
                  }

                  final numeros = texto.replaceAll(RegExp(r'\D'), '');

                  if (numeros.length != 10 && numeros.length != 11) {
                    return 'Informe um telefone válido';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Situação do paciente.
              DropdownButtonFormField<StatusPaciente>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Situação do paciente',
                  prefixIcon: Icon(Icons.assignment_outlined),
                ),
                items: StatusPaciente.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.descricao),
                  );
                }).toList(),
                onChanged: (status) {
                  if (status != null) {
                    setState(() {
                      _status = status;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              FilledButton.icon(
                key: const Key('btn_salvar_paciente'),
                onPressed: _salvar,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Salvar paciente'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/paciente.dart';

class PacientesScreen extends StatefulWidget {
  final List<Paciente> pacientes;
  final ValueChanged<Paciente> onCadastrar;
  final ValueChanged<Paciente>? onEditar;

  const PacientesScreen({
    super.key,
    required this.pacientes,
    required this.onCadastrar,
    this.onEditar,
  });

  @override
  State<PacientesScreen> createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  final _pesquisaController = TextEditingController();

  String _pesquisa = '';
  StatusPaciente? _filtroStatus;

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  // Normaliza nomes para pesquisa sem acentos e maiúsculas.
  String _normalizar(String texto) {
    return texto
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll('ç', 'c');
  }

  // Aplica pesquisa, filtro e ordenação alfabética.
  List<Paciente> get _pacientesFiltrados {
    final pesquisaNormalizada = _normalizar(_pesquisa.trim());

    final resultados = widget.pacientes.where((paciente) {
      final correspondeNome = _normalizar(paciente.nome)
          .contains(pesquisaNormalizada);

      final correspondeStatus =
          _filtroStatus == null || paciente.status == _filtroStatus;

      return correspondeNome && correspondeStatus;
    }).toList();

    resultados.sort(
      (a, b) => _normalizar(a.nome).compareTo(_normalizar(b.nome)),
    );

    return resultados;
  }

  void _limparPesquisa() {
    _pesquisaController.clear();

    setState(() {
      _pesquisa = '';
    });
  }

  void _limparFiltros() {
    _pesquisaController.clear();

    setState(() {
      _pesquisa = '';
      _filtroStatus = null;
    });
  }

  // Abre o formulário para cadastrar um paciente.
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

    widget.onCadastrar(paciente);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paciente cadastrado com sucesso!')),
    );
  }

  // Abre o formulário preenchido para editar um paciente.
  Future<void> _abrirEdicao(BuildContext context, Paciente paciente) async {
    if (widget.onEditar == null) {
      return;
    }

    final atualizado = await showModalBottomSheet<Paciente>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return FormularioPaciente(paciente: paciente);
      },
    );

    if (atualizado == null || !context.mounted) {
      return;
    }

    widget.onEditar!(atualizado);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paciente atualizado com sucesso!')),
    );
  }

  Widget _criarFiltro({
    required String titulo,
    required StatusPaciente? status,
    required String identificador,
  }) {
    return ChoiceChip(
      key: Key(identificador),
      label: Text(titulo),
      selected: _filtroStatus == status,
      onSelected: (_) {
        setState(() {
          _filtroStatus = status;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pacientesFiltrados = _pacientesFiltrados;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Meus pacientes',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Chip(label: Text('${widget.pacientes.length}')),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'Organize os pacientes cadastrados '
            'em seu consultório.',
          ),

          const SizedBox(height: 20),

          // Pesquisa por nome.
          TextField(
            key: const Key('campo_pesquisa_paciente'),
            controller: _pesquisaController,
            onChanged: (valor) {
              setState(() {
                _pesquisa = valor;
              });
            },
            decoration: InputDecoration(
              labelText: 'Pesquisar pacientes',
              hintText: 'Digite o nome do paciente',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _pesquisa.isNotEmpty
                  ? IconButton(
                      key: const Key('btn_limpar_pesquisa'),
                      tooltip: 'Limpar pesquisa',
                      onPressed: _limparPesquisa,
                      icon: const Icon(Icons.close),
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Filtrar por situação',
            style: Theme.of(context).textTheme.titleSmall,
          ),

          const SizedBox(height: 8),

          // Filtros por situação.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _criarFiltro(
                  titulo: 'Todos',
                  status: null,
                  identificador: 'filtro_todos',
                ),

                const SizedBox(width: 8),

                _criarFiltro(
                  titulo: 'Em atendimento',
                  status: StatusPaciente.emAtendimento,
                  identificador: 'filtro_em_atendimento',
                ),

                const SizedBox(width: 8),

                _criarFiltro(
                  titulo: 'Fila de espera',
                  status: StatusPaciente.emEspera,
                  identificador: 'filtro_em_espera',
                ),

                const SizedBox(width: 8),

                _criarFiltro(
                  titulo: 'Concluído',
                  status: StatusPaciente.concluido,
                  identificador: 'filtro_concluido',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Cadastro de pacientes.
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

          if (widget.pacientes.isNotEmpty) ...[
            Text(
              '${pacientesFiltrados.length} '
              '${pacientesFiltrados.length == 1 ? 'resultado' : 'resultados'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
          ],

          // Exibição da listagem.
          if (pacientesFiltrados.isEmpty)
            SizedBox(
              height: 250,
              child: widget.pacientes.isEmpty
                  ? const _ListaVazia()
                  : _SemResultados(onLimparFiltros: _limparFiltros),
            )
          else
            ...pacientesFiltrados.map(
              (paciente) => _CardPaciente(
                paciente: paciente,
                onEditar: widget.onEditar == null
                    ? null
                    : () => _abrirEdicao(context, paciente),
              ),
            ),
        ],
      ),
    );
  }
}

// Mensagem quando não existem pacientes.
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

// Mensagem quando a pesquisa não encontra pacientes.
class _SemResultados extends StatelessWidget {
  final VoidCallback onLimparFiltros;

  const _SemResultados({required this.onLimparFiltros});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(height: 16),

          Text(
            'Nenhum paciente encontrado',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 8),

          const Text(
            'Tente outro nome ou altere o filtro.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            key: const Key('btn_limpar_filtros'),
            onPressed: onLimparFiltros,
            icon: const Icon(Icons.filter_alt_off),
            label: const Text('Limpar filtros'),
          ),
        ],
      ),
    );
  }
}

// Card de cada paciente, incluindo o botão Editar.
class _CardPaciente extends StatelessWidget {
  final Paciente paciente;
  final VoidCallback? onEditar;

  const _CardPaciente({required this.paciente, this.onEditar});

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

          trailing: onEditar == null
              ? null
              : IconButton(
                  key: Key('btn_editar_${paciente.id}'),
                  tooltip: 'Editar paciente',
                  onPressed: onEditar,
                  icon: const Icon(Icons.edit_outlined),
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

// Formulário reutilizado para cadastro e edição.
class FormularioPaciente extends StatefulWidget {
  final Paciente? paciente;

  const FormularioPaciente({super.key, this.paciente});

  @override
  State<FormularioPaciente> createState() => _FormularioPacienteState();
}

class _FormularioPacienteState extends State<FormularioPaciente> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _idadeController = TextEditingController();
  final _telefoneController = TextEditingController();

  StatusPaciente _status = StatusPaciente.emAtendimento;

  bool get _editando => widget.paciente != null;

  @override
  void initState() {
    super.initState();

    final paciente = widget.paciente;

    if (paciente != null) {
      _nomeController.text = paciente.nome;
      _idadeController.text = paciente.idade.toString();
      _telefoneController.text = paciente.telefone;
      _status = paciente.status;
    }
  }

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
      // Na edição, mantém o identificador original.
      id:
          widget.paciente?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
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
                _editando ? 'Editar paciente' : 'Cadastrar paciente',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 8),

              Text(
                _editando
                    ? 'Atualize as informações do paciente.'
                    : 'Preencha as informações do paciente.',
              ),

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
                label: Text(
                  _editando ? 'Salvar alterações' : 'Salvar paciente',
                ),
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

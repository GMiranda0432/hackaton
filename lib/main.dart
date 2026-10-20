import 'package:flutter/material.dart';

import 'models/agendamento.dart';
import 'models/paciente.dart';
import 'models/profissional.dart';

import 'screens/agenda_screen.dart';
import 'screens/cadastro_profissional_screen.dart';
import 'screens/pacientes_screen.dart';
import 'screens/recursos_screen.dart';

import 'services/armazenamento_local.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BemTeVerApp());
}

class BemTeVerApp extends StatelessWidget {
  const BemTeVerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bem-te-Ver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD97706)),
        scaffoldBackgroundColor: const Color(0xFFFAF9F6),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const EntradaApp(),
    );
  }
}

class EntradaApp extends StatefulWidget {
  const EntradaApp({super.key});

  @override
  State<EntradaApp> createState() => _EntradaAppState();
}

class _EntradaAppState extends State<EntradaApp> {
  final ArmazenamentoLocal _armazenamento = ArmazenamentoLocal();

  Profissional? profissionalCadastrado;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarProfissional();
  }

  // Recupera o profissional salvo localmente, se existir.
  Future<void> _carregarProfissional() async {
    Profissional? profissional;

    try {
      profissional = await _armazenamento.carregarProfissional();
    } catch (_) {
      // Falha ao ler o armazenamento: segue para o cadastro em vez de travar.
      profissional = null;
    }

    if (!mounted) return;

    setState(() {
      profissionalCadastrado = profissional;
      _carregando = false;
    });
  }

  // Salva o profissional cadastrado e entra no consultório.
  Future<void> _concluirCadastro(Profissional profissional) async {
    await _armazenamento.salvarProfissional(profissional);

    if (!mounted) return;

    setState(() {
      profissionalCadastrado = profissional;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profissionalCadastrado == null) {
      return CadastroProfissionalScreen(
        onCadastroConcluido: _concluirCadastro,
      );
    }

    return TelaPrincipal(profissional: profissionalCadastrado!);
  }
}

class TelaPrincipal extends StatefulWidget {
  final Profissional profissional;

  const TelaPrincipal({super.key, required this.profissional});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final ArmazenamentoLocal _armazenamento = ArmazenamentoLocal();

  int paginaAtual = 0;

  final List<Paciente> _pacientes = [];
  final List<Agendamento> _agendamentos = [];

  bool _carregando = true;

  final List<String> titulos = [
    'Pacientes',
    'Agenda',
    'Recursos',
    'Consultório',
  ];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  // Recupera pacientes e agendamentos salvos localmente.
  Future<void> _carregarDados() async {
    var pacientes = <Paciente>[];
    var agendamentos = <Agendamento>[];

    try {
      pacientes = await _armazenamento.carregarPacientes();
      agendamentos = await _armazenamento.carregarAgendamentos();
    } catch (_) {
      // Falha ao ler o armazenamento: abre o app vazio em vez de travar.
      pacientes = [];
      agendamentos = [];
    }

    if (!mounted) return;

    setState(() {
      _pacientes
        ..clear()
        ..addAll(pacientes);
      _agendamentos
        ..clear()
        ..addAll(agendamentos);
      _carregando = false;
    });
  }

  // Grava a lista de pacientes no armazenamento local.
  void _persistirPacientes() {
    _armazenamento.salvarPacientes(_pacientes);
  }

  // Grava a lista de agendamentos no armazenamento local.
  void _persistirAgendamentos() {
    _armazenamento.salvarAgendamentos(_agendamentos);
  }

  // Cadastra um novo paciente.
  void _cadastrarPaciente(Paciente paciente) {
    setState(() {
      _pacientes.add(paciente);
    });
    _persistirPacientes();
  }

  // Atualiza um paciente existente, preservando seu ID.
  void _editarPaciente(Paciente atualizado) {
    final indice = _pacientes.indexWhere(
      (paciente) => paciente.id == atualizado.id,
    );

    if (indice == -1) {
      return;
    }

    setState(() {
      _pacientes[indice] = atualizado;
    });
    _persistirPacientes();
  }

  // Verifica se o paciente possui consultas vinculadas.
  bool _possuiAgendamentos(String pacienteId) {
    return _agendamentos.any(
      (agendamento) => agendamento.pacienteId == pacienteId,
    );
  }

  // Exclui somente pacientes existentes sem agendamentos.
  bool _excluirPaciente(String pacienteId) {
    final existePaciente = _pacientes.any(
      (paciente) => paciente.id == pacienteId,
    );

    if (!existePaciente || _possuiAgendamentos(pacienteId)) {
      return false;
    }

    setState(() {
      _pacientes.removeWhere((paciente) => paciente.id == pacienteId);
    });
    _persistirPacientes();

    return true;
  }

  // Adiciona ou atualiza um agendamento.
  void _salvarAgendamento(Agendamento agendamento) {
    setState(() {
      final indice = _agendamentos.indexWhere(
        (item) => item.id == agendamento.id,
      );

      if (indice == -1) {
        _agendamentos.add(agendamento);
      } else {
        _agendamentos[indice] = agendamento;
      }
    });
    _persistirAgendamentos();
  }

  // Cancela um agendamento pelo ID.
  void _excluirAgendamento(String id) {
    setState(() {
      _agendamentos.removeWhere((agendamento) => agendamento.id == id);
    });
    _persistirAgendamentos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo-hackaton.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
              semanticLabel: 'Logo do Bem-te-Ver',
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Bem-te-Ver • ${titulos[paginaAtual]}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: paginaAtual,
              children: [
                PacientesScreen(
                  pacientes: _pacientes,
                  onCadastrar: _cadastrarPaciente,
                  onEditar: _editarPaciente,
                  onExcluir: _excluirPaciente,
                  possuiAgendamentos: _possuiAgendamentos,
                ),

                AgendaScreen(
                  pacientes: _pacientes,
                  agendamentos: _agendamentos,
                  onSalvar: _salvarAgendamento,
                  onExcluir: _excluirAgendamento,
                ),

                const RecursosScreen(),

                ConsultorioScreen(profissional: widget.profissional),
              ],
            ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: paginaAtual,
        onDestinationSelected: (indice) {
          setState(() {
            paginaAtual = indice;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Pacientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa),
            label: 'Recursos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Consultório',
          ),
        ],
      ),
    );
  }
}

class ConsultorioScreen extends StatelessWidget {
  final Profissional profissional;

  const ConsultorioScreen({super.key, required this.profissional});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Meu consultório',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/logo-hackaton.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  semanticLabel: 'Logo do Bem-te-Ver',
                ),
                const SizedBox(height: 12),
                Text(
                  profissional.nome,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(profissional.email),
                const SizedBox(height: 8),
                Text(profissional.tipo.descricao),
                const SizedBox(height: 8),
                Text(
                  '${profissional.tipo.conselho}: '
                  '${profissional.registro}',
                ),
                const SizedBox(height: 8),
                Text('UF: ${profissional.uf}'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

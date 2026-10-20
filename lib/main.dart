import 'package:flutter/material.dart';

import 'models/agendamento.dart';
import 'models/paciente.dart';
import 'models/profissional.dart';

import 'screens/agenda_screen.dart';
import 'screens/cadastro_profissional_screen.dart';
import 'screens/pacientes_screen.dart';

void main() {
  runApp(const BemTeVerApp());
}

class BemTeVerApp extends StatelessWidget {
  const BemTeVerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bem-te-ver',
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

// Controla o cadastro e a entrada do profissional.
class EntradaApp extends StatefulWidget {
  const EntradaApp({super.key});

  @override
  State<EntradaApp> createState() => _EntradaAppState();
}

class _EntradaAppState extends State<EntradaApp> {
  Profissional? profissionalCadastrado;

  @override
  Widget build(BuildContext context) {
    if (profissionalCadastrado == null) {
      return CadastroProfissionalScreen(
        onCadastroConcluido: (profissional) {
          setState(() {
            profissionalCadastrado = profissional;
          });
        },
      );
    }

    return TelaPrincipal(profissional: profissionalCadastrado!);
  }
}

// Estrutura principal do aplicativo.
class TelaPrincipal extends StatefulWidget {
  final Profissional profissional;

  const TelaPrincipal({super.key, required this.profissional});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int paginaAtual = 0;

  final List<Paciente> _pacientes = [];
  final List<Agendamento> _agendamentos = [];

  final List<String> titulos = [
    'Pacientes',
    'Agenda',
    'Recursos',
    'Consultório',
  ];

  // Cadastra um novo paciente.
  void _cadastrarPaciente(Paciente paciente) {
    setState(() {
      _pacientes.add(paciente);
    });
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
  }

  // Remove um agendamento pelo ID.
  void _excluirAgendamento(String id) {
    setState(() {
      _agendamentos.removeWhere((agendamento) => agendamento.id == id);
    });
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
              semanticLabel: 'Logo do Bem-te-ver',
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                'Bem-te-ver • ${titulos[paginaAtual]}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      body: IndexedStack(
        index: paginaAtual,
        children: [
          // Pacientes: cadastro, pesquisa, filtros e edição.
          PacientesScreen(
            pacientes: _pacientes,
            onCadastrar: _cadastrarPaciente,
            onEditar: _editarPaciente,
          ),

          // Agenda de consultas.
          AgendaScreen(
            pacientes: _pacientes,
            agendamentos: _agendamentos,
            onSalvar: _salvarAgendamento,
            onExcluir: _excluirAgendamento,
          ),

          // Recursos terapêuticos.
          const Center(child: Text('Recursos terapêuticos')),

          // Informações do profissional.
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

// Exibe os dados do profissional cadastrado.
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
                  semanticLabel: 'Logo do Bem-te-ver',
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

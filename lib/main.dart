import 'package:flutter/material.dart';

import 'models/paciente.dart';
import 'models/profissional.dart';
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

  // Armazena os pacientes durante a execução.
  final List<Paciente> _pacientes = [];

  final List<String> titulos = [
    'Pacientes',
    'Agenda',
    'Recursos',
    'Consultório',
  ];

  void _cadastrarPaciente(Paciente paciente) {
    setState(() {
      _pacientes.add(paciente);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bem-te-ver • ${titulos[paginaAtual]}')),
      body: IndexedStack(
        index: paginaAtual,
        children: [
          PacientesScreen(
            pacientes: _pacientes,
            onCadastrar: _cadastrarPaciente,
          ),
          const Center(child: Text('Área de agendamentos')),
          const Center(child: Text('Recursos terapêuticos')),
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
                const Icon(Icons.account_circle_outlined, size: 48),
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

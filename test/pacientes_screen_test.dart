import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bem_te_ver/models/paciente.dart';
import 'package:bem_te_ver/screens/pacientes_screen.dart';

void main() {
  const pacientesExemplo = [
    Paciente(
      id: '1',
      nome: 'Álvaro Reis',
      idade: 30,
      telefone: '',
      status: StatusPaciente.emAtendimento,
    ),
    Paciente(
      id: '2',
      nome: 'Bruno Souza',
      idade: 45,
      telefone: '',
      status: StatusPaciente.concluido,
    ),
    Paciente(
      id: '3',
      nome: 'Carla Menezes',
      idade: 26,
      telefone: '',
      status: StatusPaciente.emEspera,
    ),
  ];

  testWidgets('Permite cadastrar e listar um paciente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _AppTeste());

    await tester.tap(find.byKey(const Key('btn_novo_paciente')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('campo_paciente_nome')),
      'Maria Silva',
    );

    await tester.enterText(find.byKey(const Key('campo_paciente_idade')), '28');

    final salvar = find.byKey(const Key('btn_salvar_paciente'));

    await tester.ensureVisible(salvar);
    await tester.tap(salvar);
    await tester.pumpAndSettle();

    expect(find.text('Maria Silva'), findsOneWidget);
    expect(find.text('28 anos'), findsOneWidget);
  });

  testWidgets('Pesquisa pacientes sem diferenciar acentos e maiúsculas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const _AppTeste(pacientesIniciais: pacientesExemplo),
    );

    await tester.enterText(
      find.byKey(const Key('campo_pesquisa_paciente')),
      'ALVARO',
    );

    await tester.pumpAndSettle();

    expect(find.text('Álvaro Reis'), findsOneWidget);
    expect(find.text('Bruno Souza'), findsNothing);
    expect(find.text('Carla Menezes'), findsNothing);
  });

  testWidgets('Filtra pacientes pela situação', (WidgetTester tester) async {
    await tester.pumpWidget(
      const _AppTeste(pacientesIniciais: pacientesExemplo),
    );

    final filtroConcluido = find.byKey(const Key('filtro_concluido'));

    await tester.ensureVisible(filtroConcluido);
    await tester.tap(filtroConcluido);
    await tester.pumpAndSettle();

    expect(find.text('Bruno Souza'), findsOneWidget);
    expect(find.text('Álvaro Reis'), findsNothing);
    expect(find.text('Carla Menezes'), findsNothing);
  });

  testWidgets('Combina pesquisa e filtro e permite limpar os resultados', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const _AppTeste(pacientesIniciais: pacientesExemplo),
    );

    await tester.enterText(
      find.byKey(const Key('campo_pesquisa_paciente')),
      'Bruno',
    );

    await tester.tap(find.byKey(const Key('filtro_em_atendimento')));

    await tester.pumpAndSettle();

    expect(find.text('Nenhum paciente encontrado'), findsOneWidget);

    final limparFiltros = find.byKey(const Key('btn_limpar_filtros'));

    await tester.ensureVisible(limparFiltros);
    await tester.tap(limparFiltros);
    await tester.pumpAndSettle();

    expect(find.text('Álvaro Reis'), findsOneWidget);
    expect(find.text('Bruno Souza'), findsOneWidget);
    expect(find.text('Carla Menezes'), findsOneWidget);
  });
}

class _AppTeste extends StatefulWidget {
  final List<Paciente> pacientesIniciais;

  const _AppTeste({this.pacientesIniciais = const []});

  @override
  State<_AppTeste> createState() => _AppTesteState();
}

class _AppTesteState extends State<_AppTeste> {
  late final List<Paciente> _pacientes;

  @override
  void initState() {
    super.initState();
    _pacientes = [...widget.pacientesIniciais];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: PacientesScreen(
          pacientes: _pacientes,
          onCadastrar: (paciente) {
            setState(() {
              _pacientes.add(paciente);
            });
          },
        ),
      ),
    );
  }
}

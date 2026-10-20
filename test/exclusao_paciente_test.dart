
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bem_te_ver/models/paciente.dart';
import 'package:bem_te_ver/screens/pacientes_screen.dart';

const maria = Paciente(
  id: 'p1',
  nome: 'Maria Silva',
  idade: 28,
  telefone: '',
  status: StatusPaciente.emAtendimento,
);

const joao = Paciente(
  id: 'p2',
  nome: 'João Souza',
  idade: 35,
  telefone: '',
  status: StatusPaciente.emEspera,
);

void main() {
  testWidgets('Exclui somente o paciente selecionado', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _AppTesteExclusao(),
    );

    await tester.tap(
      find.byKey(const Key('btn_excluir_p1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Excluir paciente'), findsOneWidget);
    expect(find.textContaining('Maria Silva'), findsWidgets);

    await tester.tap(
      find.byKey(const Key('btn_confirmar_exclusao')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Maria Silva'), findsNothing);
    expect(find.text('João Souza'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Cancelar mantém o cadastro', (tester) async {
    await tester.pumpWidget(
      const _AppTesteExclusao(),
    );

    await tester.tap(
      find.byKey(const Key('btn_excluir_p1')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Maria Silva'), findsOneWidget);
    expect(find.text('João Souza'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('Impede excluir paciente com consulta', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _AppTesteExclusao(
        idsComConsultas: {'p1'},
      ),
    );

    await tester.tap(
      find.byKey(const Key('btn_excluir_p1')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Exclusão indisponível'),
      findsOneWidget,
    );

    expect(
      find.byKey(const Key('btn_confirmar_exclusao')),
      findsNothing,
    );

    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();

    expect(find.text('Maria Silva'), findsOneWidget);
    expect(find.text('João Souza'), findsOneWidget);
  });

  testWidgets('Exibe lista vazia ao excluir o último paciente', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _AppTesteExclusao(
        pacientesIniciais: [maria],
      ),
    );

    await tester.tap(
      find.byKey(const Key('btn_excluir_p1')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('btn_confirmar_exclusao')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Nenhum paciente cadastrado'),
      findsOneWidget,
    );
  });
}

class _AppTesteExclusao extends StatefulWidget {
  final List<Paciente> pacientesIniciais;
  final Set<String> idsComConsultas;

  const _AppTesteExclusao({
    this.pacientesIniciais = const [maria, joao],
    this.idsComConsultas = const {},
  });

  @override
  State<_AppTesteExclusao> createState() =>
      _AppTesteExclusaoState();
}

class _AppTesteExclusaoState
    extends State<_AppTesteExclusao> {
  late final List<Paciente> _pacientes;

  @override
  void initState() {
    super.initState();
    _pacientes = [...widget.pacientesIniciais];
  }

  bool _excluir(String id) {
    if (widget.idsComConsultas.contains(id)) {
      return false;
    }

    if (!_pacientes.any((paciente) => paciente.id == id)) {
      return false;
    }

    setState(() {
      _pacientes.removeWhere(
        (paciente) => paciente.id == id,
      );
    });

    return true;
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
          onExcluir: _excluir,
          possuiAgendamentos: (id) {
            return widget.idsComConsultas.contains(id);
          },
        ),
      ),
    );
  }
}

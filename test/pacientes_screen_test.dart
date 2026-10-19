
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bem_te_ver/models/paciente.dart';
import 'package:bem_te_ver/screens/pacientes_screen.dart';

void main() {
  testWidgets(
    'permite cadastrar e listar um paciente',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const _AppTeste(),
      );

      // abre o formulário
      await tester.tap(
        find.byKey(const Key('btn_novo_paciente')),
      );
      await tester.pumpAndSettle();

      // preenche os campos obrigatórios
      await tester.enterText(
        find.byKey(const Key('campo_paciente_nome')),
        'Maria Silva',
      );

      await tester.enterText(
        find.byKey(const Key('campo_paciente_idade')),
        '28',
      );

      // salva o cadastro
      final salvar = find.byKey(
        const Key('btn_salvar_paciente'),
      );

      await tester.ensureVisible(salvar);
      await tester.tap(salvar);
      await tester.pumpAndSettle();

      // verifica se o paciente aparece na lista
      expect(
        find.text('Maria Silva'),
        findsOneWidget,
      );

      expect(
        find.text('28 anos'),
        findsOneWidget,
      );
    },
  );
}

class _AppTeste extends StatefulWidget {
  const _AppTeste();

  @override
  State<_AppTeste> createState() => _AppTesteState();
}

class _AppTesteState extends State<_AppTeste> {
  final List<Paciente> _pacientes = [];

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

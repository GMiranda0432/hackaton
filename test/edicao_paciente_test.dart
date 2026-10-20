import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bem_te_ver/models/paciente.dart';
import 'package:bem_te_ver/screens/pacientes_screen.dart';

const pacientesIniciais = [
  Paciente(
    id: 'p1',
    nome: 'Maria Silva',
    idade: 28,
    telefone: '',
    status: StatusPaciente.emAtendimento,
  ),
  Paciente(
    id: 'p2',
    nome: 'João Souza',
    idade: 35,
    telefone: '',
    status: StatusPaciente.emEspera,
  ),
];

void main() {
  testWidgets('Edita um paciente sem alterar o ID nem criar duplicatas', (
    tester,
  ) async {
    Paciente? atualizado;

    await tester.pumpWidget(
      _AppTesteEdicao(
        onEditado: (paciente) {
          atualizado = paciente;
        },
      ),
    );

    // Abre o formulário de edição.
    final editar = find.byKey(const Key('btn_editar_p1'));

    await tester.ensureVisible(editar);
    await tester.tap(editar);
    await tester.pumpAndSettle();

    expect(find.text('Editar paciente'), findsOneWidget);

    // Confirma que o nome original foi carregado.
    final campoNome = find.byKey(const Key('campo_paciente_nome'));

    expect(
      tester.widget<TextFormField>(campoNome).controller!.text,
      'Maria Silva',
    );

    // Altera nome e idade.
    await tester.enterText(campoNome, 'Maria Santos');

    await tester.enterText(find.byKey(const Key('campo_paciente_idade')), '29');

    // Salva as alterações.
    final salvar = find.byKey(const Key('btn_salvar_paciente'));

    await tester.ensureVisible(salvar);
    await tester.tap(salvar);
    await tester.pumpAndSettle();

    // Confere o resultado.
    expect(atualizado?.id, 'p1');
    expect(atualizado?.nome, 'Maria Santos');
    expect(atualizado?.idade, 29);

    expect(find.text('Maria Santos'), findsOneWidget);

    expect(find.text('Maria Silva'), findsNothing);

    // O outro paciente continua na lista.
    expect(find.text('João Souza'), findsOneWidget);

    // A quantidade de pacientes não muda.
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('Cancelar a edição preserva os dados originais', (tester) async {
    Paciente? atualizado;

    await tester.pumpWidget(
      _AppTesteEdicao(
        onEditado: (paciente) {
          atualizado = paciente;
        },
      ),
    );

    final editar = find.byKey(const Key('btn_editar_p1'));

    await tester.ensureVisible(editar);
    await tester.tap(editar);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('campo_paciente_nome')),
      'Nome alterado',
    );

    // Cancela sem salvar.
    final cancelar = find.text('Cancelar');

    await tester.ensureVisible(cancelar);
    await tester.tap(cancelar);
    await tester.pumpAndSettle();

    expect(atualizado, isNull);

    expect(find.text('Maria Silva'), findsOneWidget);

    expect(find.text('Nome alterado'), findsNothing);
  });

  testWidgets('Impede edição com nome inválido', (tester) async {
    Paciente? atualizado;

    await tester.pumpWidget(
      _AppTesteEdicao(
        onEditado: (paciente) {
          atualizado = paciente;
        },
      ),
    );

    final editar = find.byKey(const Key('btn_editar_p1'));

    await tester.ensureVisible(editar);
    await tester.tap(editar);
    await tester.pumpAndSettle();

    // Um nome com apenas uma letra é inválido.
    await tester.enterText(find.byKey(const Key('campo_paciente_nome')), 'A');

    final salvar = find.byKey(const Key('btn_salvar_paciente'));

    await tester.ensureVisible(salvar);
    await tester.tap(salvar);
    await tester.pumpAndSettle();

    expect(find.text('Informe o nome do paciente'), findsOneWidget);

    // Nenhuma alteração foi enviada.
    expect(atualizado, isNull);

    // O formulário continua aberto.
    expect(find.text('Editar paciente'), findsOneWidget);
  });
}

// Aplicativo auxiliar utilizado nos testes.
class _AppTesteEdicao extends StatefulWidget {
  final ValueChanged<Paciente>? onEditado;

  const _AppTesteEdicao({this.onEditado});

  @override
  State<_AppTesteEdicao> createState() => _AppTesteEdicaoState();
}

class _AppTesteEdicaoState extends State<_AppTesteEdicao> {
  final List<Paciente> _pacientes = [...pacientesIniciais];

  void _editarPaciente(Paciente atualizado) {
    widget.onEditado?.call(atualizado);

    final indice = _pacientes.indexWhere(
      (paciente) => paciente.id == atualizado.id,
    );

    if (indice != -1) {
      setState(() {
        _pacientes[indice] = atualizado;
      });
    }
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
          onEditar: _editarPaciente,
        ),
      ),
    );
  }
}

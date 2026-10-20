import 'package:flutter_test/flutter_test.dart';
import 'package:bem_te_ver/models/agendamento.dart';

void main() {
  test('Calcula o valor de uma consulta de 90 minutos', () {
    final consulta = Agendamento(
      id: '1',
      pacienteId: '1',
      inicio: DateTime(2026, 10, 20, 9, 0),
      fim: DateTime(2026, 10, 20, 10, 30),
      valorHora: 120,
    );

    expect(consulta.valorTotal, 180);
  });

  test('Identifica agendamentos com horários conflitantes', () {
    final primeira = Agendamento(
      id: '1',
      pacienteId: '1',
      inicio: DateTime(2026, 10, 20, 9, 0),
      fim: DateTime(2026, 10, 20, 10, 0),
      valorHora: 100,
    );

    final segunda = Agendamento(
      id: '2',
      pacienteId: '2',
      inicio: DateTime(2026, 10, 20, 9, 30),
      fim: DateTime(2026, 10, 20, 10, 30),
      valorHora: 100,
    );

    expect(primeira.conflitaCom(segunda), isTrue);
  });

  test('Permite agendamentos consecutivos', () {
    final primeira = Agendamento(
      id: '1',
      pacienteId: '1',
      inicio: DateTime(2026, 10, 20, 9, 0),
      fim: DateTime(2026, 10, 20, 10, 0),
      valorHora: 100,
    );

    final segunda = Agendamento(
      id: '2',
      pacienteId: '2',
      inicio: DateTime(2026, 10, 20, 10, 0),
      fim: DateTime(2026, 10, 20, 11, 0),
      valorHora: 100,
    );

    expect(primeira.conflitaCom(segunda), isFalse);
  });
}

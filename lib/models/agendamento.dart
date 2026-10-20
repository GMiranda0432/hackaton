class Agendamento {
  final String id;
  final String pacienteId;
  final DateTime inicio;
  final DateTime fim;
  final double valorHora;

  const Agendamento({
    required this.id,
    required this.pacienteId,
    required this.inicio,
    required this.fim,
    required this.valorHora,
  });

  Duration get duracao => fim.difference(inicio);

  double get valorTotal {
    return duracao.inMinutes / 60 * valorHora;
  }

  bool conflitaCom(Agendamento outro) {
    return inicio.isBefore(outro.fim) && outro.inicio.isBefore(fim);
  }
}

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

  // Converte o agendamento para JSON, permitindo salvar localmente.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pacienteId': pacienteId,
      'inicio': inicio.toIso8601String(),
      'fim': fim.toIso8601String(),
      'valorHora': valorHora,
    };
  }

  // Reconstrói o agendamento a partir do JSON salvo.
  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'] as String,
      pacienteId: json['pacienteId'] as String,
      inicio: DateTime.parse(json['inicio'] as String),
      fim: DateTime.parse(json['fim'] as String),
      valorHora: (json['valorHora'] as num).toDouble(),
    );
  }

  Duration get duracao => fim.difference(inicio);

  double get valorTotal {
    return duracao.inMinutes / 60 * valorHora;
  }

  bool conflitaCom(Agendamento outro) {
    return inicio.isBefore(outro.fim) && outro.inicio.isBefore(fim);
  }
}

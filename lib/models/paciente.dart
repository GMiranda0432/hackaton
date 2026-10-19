
enum StatusPaciente {
  emAtendimento,
  emEspera,
  concluido;

  String get descricao {
    switch (this) {
      case StatusPaciente.emAtendimento:
        return 'Em atendimento';
      case StatusPaciente.emEspera:
        return 'Fila de espera';
      case StatusPaciente.concluido:
        return 'Concluído';
    }
  }
}

class Paciente {
  final String id;
  final String nome;
  final int idade;
  final String telefone;
  final StatusPaciente status;

  const Paciente({
    required this.id,
    required this.nome,
    required this.idade,
    required this.telefone,
    required this.status,
  });
}

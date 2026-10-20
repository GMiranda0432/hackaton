
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

  // Converte o paciente para JSON, permitindo salvar localmente.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'idade': idade,
      'telefone': telefone,
      'status': status.name,
    };
  }

  // Reconstrói o paciente a partir do JSON salvo.
  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'] as String,
      nome: json['nome'] as String,
      idade: json['idade'] as int,
      telefone: json['telefone'] as String,
      status: StatusPaciente.values.firstWhere(
        (valor) => valor.name == json['status'],
        orElse: () => StatusPaciente.emAtendimento,
      ),
    );
  }
}

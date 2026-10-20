
enum TipoProfissional {
  psicologo,
  psiquiatra;

  String get descricao {
    return this == TipoProfissional.psicologo
        ? 'Psicólogo(a)'
        : 'Psiquiatra';
  }

  String get conselho {
    return this == TipoProfissional.psicologo
        ? 'CRP'
        : 'CRM';
  }
}

class Profissional {
  final String nome;
  final String email;
  final TipoProfissional tipo;
  final String registro;
  final String uf;

  const Profissional({
    required this.nome,
    required this.email,
    required this.tipo,
    required this.registro,
    required this.uf,
  });

  // Converte o profissional para JSON, permitindo salvar localmente.
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'tipo': tipo.name,
      'registro': registro,
      'uf': uf,
    };
  }

  // Reconstrói o profissional a partir do JSON salvo.
  factory Profissional.fromJson(Map<String, dynamic> json) {
    return Profissional(
      nome: json['nome'] as String,
      email: json['email'] as String,
      tipo: TipoProfissional.values.firstWhere(
        (valor) => valor.name == json['tipo'],
        orElse: () => TipoProfissional.psicologo,
      ),
      registro: json['registro'] as String,
      uf: json['uf'] as String,
    );
  }
}

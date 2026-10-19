
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
}

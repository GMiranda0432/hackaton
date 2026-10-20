import 'dart:convert';

import '../models/agendamento.dart';
import '../models/paciente.dart';
import '../models/profissional.dart';

// Backend por plataforma: arquivos JSON no aparelho (Android/iOS/desktop) ou
// armazenamento local do navegador (web).
import 'armazenamento_local_io.dart'
    if (dart.library.html) 'armazenamento_local_web.dart';

/// Persistência local dos dados do consultório.
///
/// Grava o profissional (usuário), os pacientes e os agendamentos como JSON,
/// para que continuem disponíveis ao fechar e reabrir o app. Nenhuma operação
/// trava a interface: falhas de leitura/gravação são ignoradas.
class ArmazenamentoLocal {
  static const String _chaveProfissional = 'profissional';
  static const String _chavePacientes = 'pacientes';
  static const String _chaveAgendamentos = 'agendamentos';

  // Usuário (profissional cadastrado).
  Future<Profissional?> carregarProfissional() async {
    final conteudo = await lerArquivoJson(_chaveProfissional);

    if (conteudo == null || conteudo.trim().isEmpty) {
      return null;
    }

    try {
      return Profissional.fromJson(
        jsonDecode(conteudo) as Map<String, dynamic>,
      );
    } catch (_) {
      // Dados antigos ou corrompidos: ignora para não travar a abertura.
      return null;
    }
  }

  Future<void> salvarProfissional(Profissional profissional) {
    return gravarArquivoJson(
      _chaveProfissional,
      jsonEncode(profissional.toJson()),
    );
  }

  // Pacientes (clientes) cadastrados.
  Future<List<Paciente>> carregarPacientes() async {
    final conteudo = await lerArquivoJson(_chavePacientes);

    if (conteudo == null || conteudo.trim().isEmpty) {
      return [];
    }

    try {
      final lista = jsonDecode(conteudo) as List<dynamic>;
      return lista
          .whereType<Map>()
          .map((item) => Paciente.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      // Dados antigos ou corrompidos: ignora para não travar a abertura.
      return [];
    }
  }

  Future<void> salvarPacientes(List<Paciente> pacientes) {
    return gravarArquivoJson(
      _chavePacientes,
      jsonEncode(pacientes.map((paciente) => paciente.toJson()).toList()),
    );
  }

  // Agendamentos da agenda.
  Future<List<Agendamento>> carregarAgendamentos() async {
    final conteudo = await lerArquivoJson(_chaveAgendamentos);

    if (conteudo == null || conteudo.trim().isEmpty) {
      return [];
    }

    try {
      final lista = jsonDecode(conteudo) as List<dynamic>;
      return lista
          .whereType<Map>()
          .map((item) => Agendamento.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      // Dados antigos ou corrompidos: ignora para não travar a abertura.
      return [];
    }
  }

  Future<void> salvarAgendamentos(List<Agendamento> agendamentos) {
    return gravarArquivoJson(
      _chaveAgendamentos,
      jsonEncode(
        agendamentos.map((agendamento) => agendamento.toJson()).toList(),
      ),
    );
  }
}

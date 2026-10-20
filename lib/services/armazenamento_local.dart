import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/agendamento.dart';
import '../models/paciente.dart';
import '../models/profissional.dart';

/// Persistência local dos dados do consultório.
///
/// Grava o profissional (usuário), os pacientes e os agendamentos como JSON
/// no armazenamento do dispositivo, para que continuem disponíveis ao fechar
/// e reabrir o app.
class ArmazenamentoLocal {
  static const String _chaveProfissional = 'profissional';
  static const String _chavePacientes = 'pacientes';
  static const String _chaveAgendamentos = 'agendamentos';

  // Usuário (profissional cadastrado).
  Future<Profissional?> carregarProfissional() async {
    final prefs = await SharedPreferences.getInstance();
    final conteudo = prefs.getString(_chaveProfissional);

    if (conteudo == null) {
      return null;
    }

    return Profissional.fromJson(jsonDecode(conteudo) as Map<String, dynamic>);
  }

  Future<void> salvarProfissional(Profissional profissional) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chaveProfissional,
      jsonEncode(profissional.toJson()),
    );
  }

  // Pacientes (clientes) cadastrados.
  Future<List<Paciente>> carregarPacientes() async {
    final prefs = await SharedPreferences.getInstance();
    final conteudo = prefs.getString(_chavePacientes);

    if (conteudo == null) {
      return [];
    }

    final lista = jsonDecode(conteudo) as List<dynamic>;
    return lista
        .map((item) => Paciente.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> salvarPacientes(List<Paciente> pacientes) async {
    final prefs = await SharedPreferences.getInstance();
    final conteudo = jsonEncode(
      pacientes.map((paciente) => paciente.toJson()).toList(),
    );
    await prefs.setString(_chavePacientes, conteudo);
  }

  // Agendamentos da agenda.
  Future<List<Agendamento>> carregarAgendamentos() async {
    final prefs = await SharedPreferences.getInstance();
    final conteudo = prefs.getString(_chaveAgendamentos);

    if (conteudo == null) {
      return [];
    }

    final lista = jsonDecode(conteudo) as List<dynamic>;
    return lista
        .map((item) => Agendamento.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> salvarAgendamentos(List<Agendamento> agendamentos) async {
    final prefs = await SharedPreferences.getInstance();
    final conteudo = jsonEncode(
      agendamentos.map((agendamento) => agendamento.toJson()).toList(),
    );
    await prefs.setString(_chaveAgendamentos, conteudo);
  }
}

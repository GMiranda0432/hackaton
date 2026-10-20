import 'package:shared_preferences/shared_preferences.dart';

/// No navegador não existe sistema de arquivos, então os JSONs são guardados
/// no armazenamento local do próprio navegador.
Future<String?> lerArquivoJson(String nome) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(nome);
  } catch (_) {
    return null;
  }
}

Future<void> gravarArquivoJson(String nome, String conteudo) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(nome, conteudo);
  } catch (_) {
    // Falha de gravação não deve interromper o uso do app.
  }
}

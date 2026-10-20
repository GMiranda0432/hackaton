import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Grava os dados como arquivos JSON no armazenamento do dispositivo.
///
/// Usa apenas `dart:io`, sem depender de plugins para salvar. Se o plugin de
/// diretórios não estiver disponível, ainda funciona usando a pasta do
/// aplicativo, que permanece entre as execuções.
Directory? _diretorio;

// Fila que garante a ordem das gravações (evita escrita concorrente).
Future<void> _fila = Future<void>.value();

Future<String?> lerArquivoJson(String nome) async {
  try {
    final arquivo = await _arquivo(nome);

    if (!await arquivo.exists()) {
      return null;
    }

    return await arquivo.readAsString();
  } catch (_) {
    return null;
  }
}

Future<void> gravarArquivoJson(String nome, String conteudo) {
  _fila = _fila.then((_) => _gravar(nome, conteudo));
  return _fila;
}

Future<void> _gravar(String nome, String conteudo) async {
  try {
    final arquivo = await _arquivo(nome);
    await arquivo.parent.create(recursive: true);
    await arquivo.writeAsString(conteudo, flush: true);
  } catch (_) {
    // Falha de gravação não deve interromper o uso do app.
  }
}

Future<File> _arquivo(String nome) async {
  final diretorio = _diretorio ??= await _resolverDiretorio();
  return File('${diretorio.path}${Platform.pathSeparator}$nome.json');
}

Future<Directory> _resolverDiretorio() async {
  try {
    return await getApplicationDocumentsDirectory();
  } catch (_) {
    return Directory.systemTemp;
  }
}

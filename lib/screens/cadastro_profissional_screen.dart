import 'package:flutter/material.dart';

import '../models/profissional.dart';

class CadastroProfissionalScreen extends StatefulWidget {
  final ValueChanged<Profissional> onCadastroConcluido;

  const CadastroProfissionalScreen({
    super.key,
    required this.onCadastroConcluido,
  });

  @override
  State<CadastroProfissionalScreen> createState() =>
      _CadastroProfissionalScreenState();
}

class _CadastroProfissionalScreenState
    extends State<CadastroProfissionalScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _registroController = TextEditingController();

  TipoProfissional _tipo = TipoProfissional.psicologo;
  String _uf = 'ES';

  static const List<String> _ufs = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _registroController.dispose();
    super.dispose();
  }

  // Verifica o formato informado para CRP ou CRM.
  bool _formatoRegistroValido(String registro) {
    if (_tipo == TipoProfissional.psicologo) {
      return RegExp(r'^\d{1,2}/\d{4,6}$').hasMatch(registro);
    }

    return RegExp(r'^\d{4,7}$').hasMatch(registro);
  }

  Future<void> _confirmarCadastro() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profissional = Profissional(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      tipo: _tipo,
      registro: _registroController.text.trim(),
      uf: _uf,
    );

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cadastro concluído!'),
          content: const Text(
            'Seja bem-vindo(a) ao Bem-te-Ver! '
            'Seu cadastro foi realizado com sucesso.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (confirmar == true) {
      widget.onCadastroConcluido(profissional);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Logo oficial do Bem-te-Ver.
                    Center(
                      child: Image.asset(
                        'assets/images/logo-hackaton.png',
                        key: const Key('logo_cadastro'),
                        width: 160,
                        height: 120,
                        fit: BoxFit.contain,
                        semanticLabel: 'Logo do Bem-te-Ver',
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Bem-te-Ver',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Organize seu consultório '
                      'em um só lugar',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'Cadastro do profissional',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),

                    const SizedBox(height: 20),

                    // Nome completo.
                    TextFormField(
                      key: const Key('campo_nome'),
                      controller: _nomeController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().length < 3) {
                          return 'Informe seu nome completo';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // E-mail.
                    TextFormField(
                      key: const Key('campo_email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (valor) {
                        final email = valor?.trim() ?? '';

                        final formato = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                        if (!formato.hasMatch(email)) {
                          return 'Informe um e-mail válido';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Profissão.
                    DropdownButtonFormField<TipoProfissional>(
                      initialValue: _tipo,
                      decoration: const InputDecoration(
                        labelText: 'Profissão',
                        prefixIcon: Icon(Icons.work_outline),
                      ),
                      items: TipoProfissional.values.map((tipo) {
                        return DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo.descricao),
                        );
                      }).toList(),
                      onChanged: (tipo) {
                        if (tipo == null) return;

                        setState(() {
                          _tipo = tipo;
                          _registroController.clear();
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Estado do conselho profissional.
                    DropdownButtonFormField<String>(
                      initialValue: _uf,
                      decoration: const InputDecoration(
                        labelText: 'Estado (UF)',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: _ufs.map((uf) {
                        return DropdownMenuItem(value: uf, child: Text(uf));
                      }).toList(),
                      onChanged: (uf) {
                        if (uf == null) return;

                        setState(() {
                          _uf = uf;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Registro profissional.
                    TextFormField(
                      key: const Key('campo_registro'),
                      controller: _registroController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Número do ${_tipo.conselho}',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        hintText: _tipo == TipoProfissional.psicologo
                            ? '16/12345'
                            : '123456',
                      ),
                      validator: (valor) {
                        final registro = valor?.trim() ?? '';

                        if (registro.isEmpty) {
                          return 'Informe o registro';
                        }

                        if (!_formatoRegistroValido(registro)) {
                          return 'Formato de registro inválido';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // Botão de cadastro.
                    FilledButton.icon(
                      key: const Key('btn_cadastrar'),
                      onPressed: _confirmarCadastro,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Concluir cadastro'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


# Bem-te-ver 🐦

**Sistema de gestão de consultórios de psicologia e psiquiatria**

Projeto desenvolvido durante o Hackathon IFES 2026, com o tema **Economia Local e Pequenos Negócios**.

## Sobre o projeto

O Bem-te-ver é um protótipo de aplicativo desenvolvido em Flutter para auxiliar psicólogos e psiquiatras autônomos na organização de seus consultórios.

A proposta é oferecer uma ferramenta simples e acessível para profissionais que atuam especialmente em municípios de pequeno porte e regiões rurais.

O aplicativo centraliza o cadastro de pacientes, o gerenciamento de consultas e recursos terapêuticos de apoio ao atendimento.

## Problema identificado

Profissionais autônomos podem encontrar dificuldades para organizar os dados de pacientes, controlar horários e administrar seus atendimentos, especialmente quando dependem de cadernos, planilhas e anotações dispersas.

O Bem-te-ver busca simplificar essas atividades administrativas em uma única interface.

## Funcionalidades implementadas

### Cadastro profissional

- Cadastro de psicólogos e psiquiatras.
- Seleção da categoria profissional.
- Validação dos campos obrigatórios.
- Validação demonstrativa do formato do CRP ou CRM.
- Visualização das informações do profissional.

**Observação:** os registros profissionais não são consultados em bases oficiais.

### Gerenciamento de pacientes

- Cadastro de pacientes.
- Listagem em ordem alfabética.
- Pesquisa por nome, sem diferenciação de acentos e maiúsculas.
- Filtros por situação do atendimento.
- Edição dos dados cadastrados.
- Exclusão mediante confirmação.
- Proteção contra exclusão de pacientes com consultas vinculadas.

### Agenda de consultas

- Agendamento de consultas.
- Seleção de paciente, data e horário.
- Definição do valor por hora.
- Cálculo automático do valor total da consulta.
- Verificação de conflitos de horários.
- Edição e cancelamento de agendamentos.
- Validação de valores e horários.

### Recursos terapêuticos

- Exercícios de respiração guiada.
- Técnicas respiratórias com temporizador e animação.
- Questionário PHQ-9 para rastreamento de sintomas depressivos.
- Exibição da pontuação e da classificação após o preenchimento.
- Alerta específico para resposta positiva à pergunta sobre morte ou autoagressão.
- Consulta informativa de sinais e sintomas de transtornos mentais.

**Atenção:** os recursos terapêuticos são ferramentas auxiliares e não substituem avaliação clínica, diagnóstico ou conduta de um profissional habilitado.

## Tecnologias utilizadas

- Flutter
- Dart
- Material Design 3
- Android Studio
- Visual Studio Code
- Git e GitHub

## Estrutura principal do projeto

```text
hackaton/
├── assets/
│   └── images/
│       └── logo-hackaton.png
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── agendamento.dart
│   │   ├── paciente.dart
│   │   └── profissional.dart
│   └── screens/
│       ├── agenda_screen.dart
│       ├── cadastro_profissional_screen.dart
│       ├── pacientes_screen.dart
│       └── recursos_screen.dart
├── test/
│   ├── agendamento_test.dart
│   ├── edicao_paciente_test.dart
│   ├── exclusao_paciente_test.dart
│   ├── pacientes_screen_test.dart
│   └── widget_test.dart
├── android/
├── web/
├── pubspec.yaml
└── README.md
```

## Instalação e execução

É necessário ter o Flutter SDK instalado e configurado.

Clone o repositório:

```bash
git clone https://github.com/GMiranda0432/hackaton.git
```

Entre na pasta:

```bash
cd hackaton
```

Instale as dependências:

```bash
flutter pub get
```

Execute o aplicativo:

```bash
flutter run
```

Para executar no navegador Chrome:

```bash
flutter run -d chrome
```

## Verificações

Análise estática:

```bash
flutter analyze
```

Testes automatizados:

```bash
flutter test
```

## Limitações do protótipo

O Bem-te-ver foi desenvolvido como um produto mínimo viável (MVP) durante um hackathon de 24 horas.

Nesta versão:

- Os dados ficam armazenados temporariamente na memória do aplicativo.
- Os cadastros e agendamentos não são preservados após o encerramento da aplicação.
- Não existe autenticação segura ou validação oficial de registro profissional.
- Não existe integração com sistemas externos de saúde.
- Os recursos clínicos são demonstrativos e informativos.

Por essas limitações, o protótipo deve ser demonstrado somente com dados fictícios, sem informações reais ou sensíveis de pacientes.

## Melhorias futuras

- Persistência local ou em banco de dados.
- Autenticação e controle de acesso.
- Proteção e tratamento adequado de dados pessoais e sensíveis.
- Lembretes de consultas.
- Relatórios administrativos.
- Ampliação dos recursos terapêuticos.
- Validação do aplicativo com profissionais da área.

## Hackathon IFES 2026

**Tema:** Economia Local e Pequenos Negócios.

O projeto busca apoiar profissionais autônomos na administração de pequenos consultórios, contribuindo para a organização dos serviços e o fortalecimento da economia local.

O desenvolvimento contou com o auxílio de ferramentas de inteligência artificial, incluindo o ChatGPT, para apoio à programação, revisão e organização do projeto.

**Repositório:** https://github.com/GMiranda0432/hackaton

---

**Bem-te-ver — Tecnologia e organização a serviço do cuidado.**


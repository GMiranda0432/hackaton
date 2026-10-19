# BEM-TE-VER
### Sistema de Gestão e Organização para Profissionais de Saúde Mental

## 1. SOBRE O PROJETO

O **Bem-te-ver** é um aplicativo desenvolvido com Flutter, destinado a auxiliar psicólogos e psiquiatras na organização e no gerenciamento de seus atendimentos, especialmente em municípios de pequeno porte e regiões rurais.

O projeto tem como objetivo oferecer uma solução tecnológica acessível e intuitiva para profissionais autônomos que enfrentam dificuldades na administração de seus consultórios, proporcionando maior praticidade no controle de pacientes, agendamentos e informações relacionadas aos atendimentos.

A iniciativa foi desenvolvida durante o **Hackathon IFES 2026**, cujo tema é **Economia Local e Pequenos Negócios**.

## 2. OBJETIVOS

O principal objetivo do Bem-te-ver é facilitar a gestão de pequenos consultórios por meio de uma aplicação que centralize informações e simplifique atividades administrativas.

Entre seus objetivos específicos, destacam-se:

- Facilitar o cadastro e a organização de pacientes.
- Proporcionar maior controle sobre agendamentos e horários de atendimento.
- Reduzir a dependência de registros físicos e anotações dispersas.
- Oferecer uma interface intuitiva e acessível.
- Contribuir para a organização de profissionais autônomos que atuam em comunidades locais.

## 3. FUNCIONALIDADES

### 3.1. Funcionalidades Implementadas

- Cadastro de profissionais de saúde mental.
- Seleção da categoria profissional: Psicólogo ou Psiquiatra.
- Validação simulada do formato do registro profissional (CRP ou CRM).
- Validação dos campos obrigatórios do formulário.
- Navegação entre as seções Pacientes, Agenda, Recursos e Consultório.
- Visualização das informações do profissional cadastrado.

### 3.2. Funcionalidades em Desenvolvimento

- Cadastro, edição, consulta e exclusão de pacientes.
- Pesquisa e filtragem de pacientes cadastrados.
- Gerenciamento de agendamentos e horários.
- Organização de registros de atendimentos.
- Implementação de armazenamento persistente.
- Desenvolvimento de recursos complementares de apoio aos profissionais.

## 4. TECNOLOGIAS UTILIZADAS

O desenvolvimento do aplicativo utiliza as seguintes tecnologias e ferramentas:

| Tecnologia | Finalidade |
|---|---|
| Flutter | Framework para desenvolvimento da aplicação. |
| Dart | Linguagem de programação principal. |
| Material Design 3 | Componentes e padrões de interface. |
| Android Studio | Emulação e ferramentas de desenvolvimento Android. |
| Visual Studio Code | Ambiente de edição e desenvolvimento. |
| Git | Controle de versões do código-fonte. |
| GitHub | Hospedagem do repositório e colaboração da equipe. |

## 5. ESTRUTURA DO PROJETO

```text
hackaton/
├── android/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── profissional.dart
│   └── screens/
│       └── cadastro_profissional_screen.dart
├── test/
│   └── widget_test.dart
├── web/
├── pubspec.yaml
└── README.md
```

A estrutura será expandida conforme a implementação das novas funcionalidades.

## 6. INSTALAÇÃO E EXECUÇÃO

### Pré-requisitos

- Flutter SDK instalado e configurado.
- Android SDK para execução em dispositivos Android.
- Emulador Android ou dispositivo físico compatível.

### 6.1. Clonar o Repositório

```bash
git clone https://github.com/GMiranda0432/hackaton.git
```

### 6.2. Acessar o Diretório

```bash
cd hackaton
```

### 6.3. Instalar as Dependências

```bash
flutter pub get
```

### 6.4. Executar o Aplicativo

```bash
flutter run
```

Para executar no navegador Google Chrome:

```bash
flutter run -d chrome
```

### 6.5. Análise e Testes

Para verificar possíveis problemas no código:

```bash
flutter analyze
```

Para executar os testes automatizados:

```bash
flutter test
```

## 7. ESTÁGIO ATUAL DO DESENVOLVIMENTO

O aplicativo encontra-se em fase inicial de implementação.

Atualmente, o cadastro profissional está funcional, utilizando uma validação demonstrativa do formato do CRP ou CRM, sem consulta às bases oficiais dos respectivos conselhos profissionais.

As informações cadastradas permanecem temporariamente em memória, não sendo preservadas após o encerramento da aplicação.

As próximas etapas contemplam a implementação do gerenciamento de pacientes, agendamentos e persistência dos dados.

O repositório também contém arquivos da implementação Android nativa anterior, que serão substituídos durante a migração para Flutter.

## 8. HACKATHON IFES 2026

O Bem-te-ver é um projeto desenvolvido durante o Hackathon promovido pelo Instituto Federal do Espírito Santo (IFES), Campus Santa Teresa, em outubro de 2026.

**Tema:** Economia Local e Pequenos Negócios.

**Proposta:** Desenvolver uma solução tecnológica que contribua para a organização e o crescimento de pequenos negócios e profissionais autônomos da região.

O projeto busca atender especialmente pequenos consultórios de saúde mental, promovendo maior eficiência administrativa e contribuindo para o desenvolvimento da economia local.

## 9. EQUIPE DE DESENVOLVIMENTO

Projeto desenvolvido por uma equipe de quatro integrantes participantes do Hackathon IFES 2026.

**Repositório oficial:** https://github.com/GMiranda0432/hackaton

O desenvolvimento contou com o auxílio de ferramentas de Inteligência Artificial, incluindo o ChatGPT, utilizadas como suporte à implementação, revisão e organização do código.

---

**Bem-te-ver — Tecnologia e organização a serviço do cuidado.**

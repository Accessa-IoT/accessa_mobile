# TESTING

Este documento descreve como rodar os testes do projeto `accessa_mobile` localmente (Windows, PowerShell) e dá dicas rápidas de debug.

## Pré-requisitos

- Ter o Flutter SDK instalado e disponível no PATH.
- Para testes puros em Dart também é possível usar o `dart` tool (o projeto é Flutter, portanto prefira `flutter test`).
- Execute os comandos a partir da raiz do projeto (onde está o `pubspec.yaml`).

## Instalar dependências

No PowerShell (a partir da raiz do projeto):

```powershell
Set-Location -Path .\accessa_mobile
flutter pub get
```

Ou, se você já estiver na pasta `accessa_mobile`:

```powershell
flutter pub get
```

## Rodar todos os testes

```powershell
flutter test
```

Isso executa tanto testes unitários quanto widget tests que estejam sob a pasta `test/`.

## Rodar um arquivo de teste específico

```powershell
flutter test test/date_fmt_test.dart -r expanded
```

`-r expanded` exibe resultados detalhados por teste (útil para debugging).

## Rodar um teste por nome

```powershell
flutter test --name "nome do teste"
```

Exemplo:

```powershell
flutter test --name "fmtDateTime formats local DateTime with leading zeros"
```

## Testes puros em Dart

Se você criar bibliotecas sem dependências do Flutter, pode usar:

```powershell
dart test
```

Mas, se os testes dependem de widgets ou bindings do Flutter, use `flutter test`.

## Cobertura (opcional)

Gerar cobertura com Flutter:

```powershell
flutter test --coverage
# isso cria cobertura em coverage/lcov.info
```

Em Windows você pode usar ferramentas como `lcov`/`genhtml` (WSL, Git Bash ou via choco) para gerar um relatório HTML a partir de `coverage/lcov.info`.

## Dicas de solução de problemas

- Erro "No pubspec.yaml file found": certifique-se de executar os comandos a partir da raiz do projeto (onde está o `pubspec.yaml`).
- Se algum pacote não for encontrado, rode `flutter pub get` e verifique a conectividade.
- Para erros de import ou versão, execute `flutter pub outdated` para inspecionar dependências desatualizadas ou conflitantes.
- Para problemas com bindings em testes de widget, assegure-se de usar `flutter_test` e de chamar `TestWidgetsFlutterBinding.ensureInitialized()` quando necessário.

## Integração contínua (exemplo GitHub Actions)

Um job simples para rodar testes com Flutter (arquivo: `.github/workflows/flutter-test.yml`):

```yaml
name: Flutter tests

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
      - name: Install dependencies
        run: flutter pub get
      - name: Run tests
        run: flutter test --no-sound-null-safety
```

Ajuste `runs-on` para `ubuntu-latest` se preferir Linux runners (geralmente mais rápidos para builds).

## Próximos passos

- Adicionar mais testes unitários para serviços em `lib/data/services/` usando mocks.
- Adicionar um workflow CI com cache de pub packages para acelerar runs.

---

Se quiser, eu posso adicionar automaticamente um arquivo de workflow de CI, ou criar testes para um serviço específico — diga qual serviço você quer começar a testar.

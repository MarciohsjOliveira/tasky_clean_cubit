# Tasky Clean Cubit

Flutter app (front-end only, mock API) with Clean Architecture and Cubit.

## Requirements
- Flutter 3.22+ (stable)
- Dart 3.4+
- (Optional) lcov for HTML coverage report

## Setup
```bash
flutter pub get
flutter run -d chrome
```

## Tests & Coverage
```bash
flutter test --coverage
# optional: generate HTML
genhtml coverage/lcov.info -o coverage/html
```

## Lint
```bash
flutter analyze
```

## Web build
```bash
flutter build web
```

## Docker (serve web)
```bash
docker compose up --build
# open http://localhost:8080
```

## CI
GitHub Actions workflow: analyze, test (coverage >= 90%), build web and upload artifact.


## IA utilizada
- ChatGPT (assistente técnico para refino de arquitetura, CI/coverage e documentação)

## Acessibilidade e UX
- Tooltips e rótulos nas ações (ex.: toggle/mark as done, criar tarefa)
- `autofillHints` e `textInputAction` nos formulários de Login/Registro
- Feedback visual com SnackBars para operações de sucesso/erro
- Layout responsivo (web/mobile)

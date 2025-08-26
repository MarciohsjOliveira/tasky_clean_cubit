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

## Why this design (Clean + Cubit + Use Cases)

- **Separation of concerns**: UI (pages/widgets) fala apenas com **Cubits**; regras de negócio vivem nos **Use Cases**; persistência/mocks ficam em **Repositories/DataSource**.  
- **Testabilidade**: cada camada tem testes específicos (unit para domain/data, widget para UI, integration para o fluxo).  
- **Evolução segura**: filtros/estado do dashboard foram modelados para evitar acoplamento entre view e data (ex.: `TaskFilter`).  
- **DX**: scripts e CI adicionados para garantir qualidade contínua (analyze, cobertura, build web).

## CI / Coverage

- CI exige **cobertura ≥ 90%** automaticamente via `scripts/coverage_check.sh`.  
- Relatório HTML de cobertura é publicado como artifact em cada execução do CI.


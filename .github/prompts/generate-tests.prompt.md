---
name: generate-tests
description: Genera pruebas unitarias para backend y/o frontend en paralelo, basadas en la spec ASDD y el código implementado. Soporta código existente y herramientas personalizadas desde qa.config.md.
argument-hint: "<nombre-feature> [--backend] [--frontend] [--custom-tools] (por defecto genera ambos en paralelo)"
agent: Orchestrator
tools:
  - edit/createFile
  - edit/editFiles
  - read/readFile
  - search/listDirectory
  - search
  - execute/runInTerminal
---

Genera pruebas unitarias completas para el feature especificado.

**Feature**: ${input:featureName:nombre del feature en kebab-case}
**Scope**: ${input:scope:backend, frontend, ambos en paralelo (default), o custom-tools}
**Ruta del código a testear** *(opcional)*: ${input:existingCodePath:ruta al código ya implementado — ej. backend/app/users/ — dejar vacío para usar ruta por defecto del config}

## Pasos obligatorios:

### 1. Leer configuración (siempre primero)
Leer en paralelo:
- `.github/config/paths.config.md` → obtener `BACKEND_TESTS`, `FRONTEND_TESTS`
- `.github/config/qa.config.md` → obtener `UNIT_TEST_TOOL`, `TEST_LANGUAGE`, `COVERAGE_THRESHOLD`, `UNIT_STRUCTURE`

### 2. Verificar la spec
Lee `.github/specs/${input:featureName:nombre-feature}.spec.md` — si no existe, detente e informa al usuario.

### 3. Escanear código existente (si se proporcionó ruta)
Si `${input:existingCodePath}` no está vacío:
- Escanear la ruta para identificar la estructura real del código
- Pasar esa estructura como contexto a los Test Engineers

### 4. Delegar según scope

**Si scope = "ambos"**: lanza en paralelo `Test Engineer Backend` + `Test Engineer Frontend`.
**Si scope = "backend"**: delega a `Test Engineer Backend`.
**Si scope = "frontend"**: delega a `Test Engineer Frontend`.
**Si scope = "custom-tools"**: leer `qa.config.md` para obtener herramientas configuradas, luego delegar a ambos Test Engineers con instrucciones de usar `E2E_TOOL`, `API_TOOL` y otros tools del config.

Contexto a pasar en la delegación:
- Ruta de salida: `BACKEND_TESTS` / `FRONTEND_TESTS` de `paths.config.md`
- Tooling: `UNIT_TEST_TOOL`, `TEST_LANGUAGE` de `qa.config.md`
- Cobertura: `COVERAGE_THRESHOLD` de `qa.config.md`
- Estructura: `UNIT_STRUCTURE` de `qa.config.md`
- Código a testear: `${input:existingCodePath}` o rutas por defecto del config

### 5. Verificar que los tests corren
Segun `UNIT_TEST_TOOL` de `qa.config.md`:
- `pytest` → `cd backend && poetry run pytest tests/ -v`
- `jest` → `cd frontend && npx jest --passWithNoTests`
- `vitest` → `cd frontend && npx vitest run`
- Otras herramientas → usar el comando estándar del tool

## Cobertura obligatoria por test:
- ✅ Happy path (flujo exitoso)
- ❌ Error path (excepciones, errores de red, datos inválidos)
- 🔲 Edge cases (campos vacíos, duplicados, permisos)

## Restricciones:
- Cada test debe ser independiente (no compartir estado).
- Mockear SIEMPRE las dependencias externas (DB, auth, APIs externas).
- Adaptar patrones al tooling de `qa.config.md` — NO hardcodear pytest/vitest.
- En scope `custom-tools`: incluir instrucciones de setup de la herramienta si no está configurada.

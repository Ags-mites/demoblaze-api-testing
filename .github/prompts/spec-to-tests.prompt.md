---
name: spec-to-tests
description: Genera tests directamente desde una spec sobre código existente o recién implementado. Salta la fase de implementación — ideal para agregar cobertura a código ya escrito o para ir directo de spec aprobada a tests.
argument-hint: "<nombre-feature> [--backend] [--frontend] (por defecto genera ambos en paralelo)"
agent: Orchestrator
tools:
  - edit/createFile
  - edit/editFiles
  - read/readFile
  - search/listDirectory
  - search
  - execute/runInTerminal
---

Genera tests directamente desde la spec, sin pasar por la fase de implementación.

**Feature**: ${input:featureName:nombre del feature en kebab-case}
**Scope**: ${input:scope:backend, frontend, o ambos en paralelo (default)}
**Ruta del código a testear**: ${input:existingCodePath:ruta al código implementado — ej. backend/app/users/ (dejar vacío si es código nuevo recién implementado)}

---

## Pasos obligatorios para el @Orchestrator:

### 1. Leer configuración

Lee en paralelo:
- `.github/config/paths.config.md` → obtener `BACKEND_TESTS`, `FRONTEND_TESTS`
- `.github/config/qa.config.md` → obtener `UNIT_TEST_TOOL`, `TEST_LANGUAGE`, `COVERAGE_THRESHOLD`

### 2. Verificar la spec

Verificar que `.github/specs/${input:featureName}.spec.md` existe:

- **`APPROVED`** → continuar directamente
- **`DRAFT`** → mostrar al usuario: _"La spec está en DRAFT. ¿Deseas aprobarla ahora y continuar con la generación de tests? (sí/no)"_
- **No existe** → detener y sugerir ejecutar `/generate-spec` primero

### 3. Escanear código existente (si se proporcionó ruta)

Si `${input:existingCodePath}` no está vacío:
- Escanear el directorio real para identificar las capas existentes (routes/services/repos o pages/hooks/components)
- Documentar la estructura encontrada antes de delegar a los Test Engineers

### 4. Delegar en paralelo según scope

**Si scope incluye "backend"** → delega a `Test Engineer Backend` con contexto:
```
Feature: ${input:featureName}
Spec: .github/specs/${input:featureName}.spec.md
Código existente: ${input:existingCodePath} (o backend/app/ si vacío)
Output dir: valor de BACKEND_TESTS en paths.config.md
Tooling: valor de UNIT_TEST_TOOL y TEST_LANGUAGE en qa.config.md
```

**Si scope incluye "frontend"** → delega a `Test Engineer Frontend` con contexto:
```
Feature: ${input:featureName}
Spec: .github/specs/${input:featureName}.spec.md
Código existente: ${input:existingCodePath} (o frontend/src/ si vacío)
Output dir: valor de FRONTEND_TESTS en paths.config.md
Tooling: valor de UNIT_TEST_TOOL y TEST_LANGUAGE en qa.config.md
```

### 5. Verificar que los tests corren

Segun el `UNIT_TEST_TOOL` configurado en `qa.config.md`:
- `pytest` → `cd backend && poetry run pytest tests/ -v --tb=short`
- `jest` → `cd frontend && npx jest --passWithNoTests`
- `vitest` → `cd frontend && npx vitest run`
- Otras herramientas → usar el comando estándar del tool

---

## Cobertura obligatoria

- ✅ Happy path (flujo exitoso)
- ❌ Error path (excepciones, errores de red, datos inválidos)
- 🔲 Edge cases (campos vacíos, duplicados, permisos denegados)

## Restricciones

- NO modificar el código existente — solo generar tests.
- Adaptar los patrones de test al tooling en `qa.config.md` — no hardcodear pytest/vitest.
- Si la estructura real del código difiere de la spec, generar tests que reflejen el código real.
- Los tests deben ser independientes (cero estado compartido).

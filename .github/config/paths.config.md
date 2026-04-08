---
# ASDD — Configuración de Rutas del Proyecto
# Modifica este archivo para personalizar las rutas de tu proyecto.
# Todos los agentes leen este archivo antes de generar o escribir código.
# Si el usuario pasa una ruta diferente en el chat, esa tiene precedencia sobre este config.
---

# Configuración de Rutas

## Código Fuente

| Variable | Valor por defecto | Descripción |
|----------|-------------------|-------------|
| `BACKEND_SRC` | `backend/app/` | Directorio raíz del código fuente backend |
| `FRONTEND_SRC` | `frontend/src/` | Directorio raíz del código fuente frontend |

## Tests

| Variable | Valor por defecto | Descripción |
|----------|-------------------|-------------|
| `BACKEND_TESTS` | `backend/tests/` | Directorio de tests unitarios/integración backend |
| `FRONTEND_TESTS` | `frontend/src/__tests__/` | Directorio de tests unitarios/integración frontend |
| `E2E_TESTS` | `e2e/` | Directorio de tests end-to-end |
| `KARATE_TESTS` | `karate-api-testing/src/test/java/` | Raíz de feature files y runners de Karate DSL |
| `KARATE_FEATURES` | `karate-api-testing/src/test/java/users/` | Feature files de Karate por módulo |
| `KARATE_COMMON` | `karate-api-testing/src/test/java/common/` | Utilidades compartidas entre feature files |
| `KARATE_CONFIG` | `karate-api-testing/src/test/java/karate-config.js` | Configuración global de entorno Karate |
| `KARATE_REPORTS` | `karate-api-testing/target/karate-reports/` | Reportes HTML generados por Karate |

## Salida QA

| Variable | Valor por defecto | Descripción |
|----------|-------------------|-------------|
| `QA_OUTPUT_DIR` | `docs/output/qa/` | Directorio raíz de artefactos QA |
| `QA_REPORTS_DIR` | `docs/output/qa/reports/` | Reportes finales consolidados |

## Specs y Requerimientos

| Variable | Valor por defecto | Descripción |
|----------|-------------------|-------------|
| `SPECS_DIR` | `.github/specs/` | Especificaciones técnicas ASDD |
| `REQUIREMENTS_DIR` | `.github/requirements/` | Requerimientos de negocio |

---

## Instrucciones para agentes que lean este archivo

- Antes de escribir cualquier archivo, resolver la ruta leyendo este config.
- Si el usuario provee una ruta diferente en su mensaje, esa tiene **precedencia** sobre este config.
- Para proyectos monorepo sin separación backend/frontend, ajustar `BACKEND_SRC` y `FRONTEND_SRC` según la estructura real.
- Para proyectos de stack único (solo backend o solo frontend), ignorar las variables no aplicables.

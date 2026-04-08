---
description: 'Ejecuta el QA Agent para generar el plan de calidad completo. Soporta herramientas personalizadas desde qa.config.md y rutas configurables desde paths.config.md.'
agent: QA Agent
---

Ejecuta el QA Agent completo basado en la configuración del proyecto.

**Feature**: ${input:featureName:nombre del feature en kebab-case}
**Scope QA**: ${input:qaScope:standard (default) | custom-tools}

---

## Pasos obligatorios para el @QA Agent:

### 1. Leer configuración (siempre primero)
Leer en paralelo:
- `.github/config/qa.config.md` → tooling, lenguaje, `PERFORMANCE_TOOL`, `E2E_TOOL`, `REPORT_FORMAT`
- `.github/config/paths.config.md` → `QA_OUTPUT_DIR`, `QA_GHERKIN_DIR`, `QA_RISKS_DIR`, etc.
- `.github/docs/lineamientos/qa-guidelines.md`

### 2. Verificar la spec
Lee `.github/specs/${input:featureName}.spec.md` — debe estar en estado `APPROVED`.
Si no existe → detener y sugerir `/generate-spec` primero.

### 3. Ejecutar skills según scope

#### Si scope = `standard`
Ejecutar en orden estricto:
- SKILL 1: `/gherkin-case-generator` → `QA_GHERKIN_DIR/<feature>-gherkin.md`
- SKILL 2: `/risk-identifier` → `QA_RISKS_DIR/<feature>-risks.md`
- SKILL 3: `/performance-analyzer` → `QA_PERFORMANCE_DIR/<feature>-performance.md`
  *(solo si hay SLAs en la spec O si `PERFORMANCE_TOOL` ≠ `none` en qa.config.md)*
- SKILL 4: `/automation-flow-proposer` → `QA_AUTOMATION_DIR/automation-proposal.md`
  *(solo si el usuario lo solicita)*

#### Si scope = `custom-tools`
Ejecutar los mismos skills PERO:
- Adaptar todos los scripts y ejemplos al `E2E_TOOL`, `PERFORMANCE_TOOL` y `UNIT_TEST_TOOL` de `qa.config.md`
- Generar artefacto adicional: `QA_OUTPUT_DIR/<feature>-custom-tools-setup.md` con:
  - Instalación y configuración de las herramientas
  - Estructura de archivos recomendada
  - Comandos de ejecución ajustados al `CI_TOOL` de qa.config.md
  - Ejemplos de scripts en el tooling configurado

### 4. Generar reporte consolidado
Generar `QA_REPORTS_DIR/<feature>-qa-summary.md` con resumen de todos los artefactos producidos.

---

**Prerequisito:** `.github/specs/${input:featureName}.spec.md` con estado `APPROVED`.

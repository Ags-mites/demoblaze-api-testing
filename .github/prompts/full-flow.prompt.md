---
description: 'Orquesta el flujo completo ASDD. Soporta feature nuevo y código existente. Flujo: Spec → [Backend ∥ Frontend ∥ DB] → [Tests Backend ∥ Tests Frontend] → QA → DOC (opcional).'
agent: Orchestrator
---

Inicia el flujo ASDD. Soporta codigo nuevo o código existente.

**Feature**: ${input:featureName:nombre del feature en kebab-case}
**Requerimiento**: ${input:requirement:descripción funcional del feature — o "ver requirements" para cargar desde .github/requirements/}
**Modo**: ${input:mode:nuevo (default) | existente}
**Ruta código existente** *(solo si mode=existente)*: ${input:existingCodePath:ruta al código ya implementado, ej. backend/app/users/ — dejar vacío si mode=nuevo}

---

**El @Orchestrator ejecuta automáticamente:**

### Paso previo (siempre)
Leer en paralelo:
- `.github/config/paths.config.md` → obtener rutas de salida
- `.github/config/qa.config.md` → obtener tooling y lenguaje de tests

### Si `mode = nuevo` (flujo completo)

1. **[FASE 1]** `Spec Generator` → genera `.github/specs/${input:featureName}.spec.md`
2. **[FASE 2 — Paralelo]** al aprobar la spec:
   - `Backend Developer` → implementa en ruta `BACKEND_SRC`
   - `Frontend Developer` → implementa en ruta `FRONTEND_SRC`
   - `Database Agent` → si hay cambios de esquema en la spec
3. **[FASE 3 — Paralelo]** al completar implementación:
   - `Test Engineer Backend` → genera tests en `BACKEND_TESTS`
   - `Test Engineer Frontend` → genera tests en `FRONTEND_TESTS`
4. **[FASE 4]** `QA Agent` → estrategia, Gherkin, riesgos en `QA_OUTPUT_DIR`
5. **[FASE 5 — Opcional]** `Documentation Agent` → si el usuario lo solicita

### Si `mode = existente` (código ya implementado)

1. **[FASE 1]** `Spec Generator` → escanear `${input:existingCodePath}` → genera spec que describe el código real
2. **[FASE 2]** *Omitida* (el código ya existe)
3. **[FASE 3 — Paralelo]** al aprobar la spec:
   - `Test Engineer Backend` → genera tests en `BACKEND_TESTS` (sobre código real)
   - `Test Engineer Frontend` → genera tests en `FRONTEND_TESTS` (sobre código real)
4. **[FASE 4]** `QA Agent` → estrategia, Gherkin, riesgos en `QA_OUTPUT_DIR`
5. **[FASE 5 — Opcional]** `Documentation Agent` → si el usuario lo solicita

**El requerimiento se puede buscar también en** `.github/requirements/${input:featureName}.md`.

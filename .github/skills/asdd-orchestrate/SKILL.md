---
name: asdd-orchestrate
description: Orquesta el flujo ASDD completo. Soporta features nuevos y código existente. Flujo: Spec → Fase 2 (Backend ∥ Frontend) → Fase 3 (Tests ∥) → Fase 4 (QA). También ejecuta flujos parciales como spec-to-tests.
argument-hint: "<nombre-feature> [--existing <ruta>] [--spec-to-tests] | status"
---

# ASDD Orchestrate

## Paso 0 — Leer configuración (SIEMPRE primero)

Leer en paralelo antes de cualquier acción:
- `.github/config/paths.config.md` → rutas de código fuente, tests y QA
- `.github/config/qa.config.md` → tooling, lenguaje y estructura de QA

Usar estos valores como contexto al delegar a cualquier agente.

## Modos de operación

```
Modo A — Feature nuevo:
  [FASE 1] spec-generator → .github/specs/<feature>.spec.md (DRAFT → APPROVED)
  [FASE 2] backend-developer ∥ frontend-developer ∥ database-agent
  [FASE 3] test-engineer-backend ∥ test-engineer-frontend
  [FASE 4] qa-agent → QA_OUTPUT_DIR (de paths.config.md)

Modo B — Código existente (--existing <ruta>):
  [FASE 1] spec-generator → escanea <ruta> → genera spec
  [FASE 2] Omitida (código ya existe)
  [FASE 3] test-engineer-backend ∥ test-engineer-frontend (sobre código real)
  [FASE 4] qa-agent → QA_OUTPUT_DIR (de paths.config.md)

Modo C — Spec aprobada → Tests directamente (--spec-to-tests):
  [FASE 3] test-engineer-backend ∥ test-engineer-frontend
           (requiere spec APPROVED + código en la ruta indicada)
  [FASE 4] qa-agent (opcional)
```

## Proceso
1. Detectar modo según argumentos recibidos
2. Leer `paths.config.md` y `qa.config.md`
3. Buscar `.github/specs/<feature>.spec.md`
   - No existe → ejecuta `/generate-spec` (con escaneo de código si Modo B)
   - `DRAFT` → pedir aprobación al usuario; si el usuario aprueba y pasa `--spec-to-tests` → saltar a Fase 3
   - `APPROVED` → continuar según el modo
4. En Modo A/B: lanzar Fase 2 en paralelo (omitir en Modo B/C)
5. Lanzar Fase 3 en paralelo — pasar como contexto: tooling de `qa.config.md` y rutas de `paths.config.md`
6. Lanzar Fase 4 (qa-agent) — pasar rutas de `paths.config.md`
7. Actualizar spec a `IMPLEMENTED` y reportar estado final

## Comando status
Al recibir `status`: lista specs en `.github/specs/` con su estado y próxima acción pendiente.

## Reglas
- Sin spec `APPROVED` → no hay código — sin excepciones
- No implementar directamente — solo coordinar y delegar
- Si una fase falla → detener el flujo y notificar al usuario con contexto
- Fase 5 (doc) solo si el usuario la solicita explícitamente
- Siempre pasar rutas de configs como contexto al delegar — nunca hardcodear rutas

---
applyTo: "**/*test*/**,**/__tests__/**,**/tests/**,**/e2e/**,**/features/**"
---

# Instrucciones para Archivos de QA y Tests

## Paso 0 — Configuración obligatoria (SIEMPRE primero)

Antes de generar cualquier test, estrategia QA o artefacto, lee estos archivos en paralelo:

1. `.github/config/qa.config.md` — tooling, lenguaje, estructura, cobertura, CI
2. `.github/config/paths.config.md` — rutas de salida de tests y QA

**Todo el código y artefactos generados deben usar el tooling y lenguaje de `qa.config.md`.**
**Todas las rutas de salida deben leerse de `paths.config.md`.**

---

## Principios (independientes del tooling)

- **Independencia**: cada test 100% independiente — sin estado compartido entre tests.
- **Aislamiento**: mockear SIEMPRE dependencias externas (DB, APIs, auth, filesystem).
- **Claridad**: nombre del test describe la función bajo prueba y el escenario esperado.
- **Cobertura**: mínimo según `COVERAGE_THRESHOLD` en `qa.config.md`.

## Estructura AAA obligatoria

```
# GIVEN — preparar datos y contexto inicial
# WHEN  — ejecutar la acción bajo prueba
# THEN  — verificar el resultado esperado
```

---

## Modo código existente — análisis previo obligatorio

Si el usuario indica una ruta de código existente:

1. Escanear el directorio real antes de generar tests.
2. Inferir la estructura desde los archivos existentes — no suponer capas por convención.
3. Identificar qué dependencias son mockeables y cuáles son internas.
4. Generar tests que reflejen la implementación real, no la ideal de la spec.

---

## Reglas de diseño

- No tests que dependan del orden de ejecución.
- No llamadas reales a servicios externos en tests unitarios.
- No `console.log` ni `print` permanentes en tests.
- No lógica condicional (if/else) dentro de un test.
- No `sleep` / `time.sleep` para sincronización — usar mocks o awaits.

---

## DoR de Automatización

Antes de automatizar un flujo, verificar:

- [ ] Caso ejecutado exitosamente en manual sin bugs críticos
- [ ] Caso de prueba documentado con datos identificados
- [ ] Viabilidad técnica comprobada con la herramienta en `qa.config.md`
- [ ] Ambiente estable disponible
- [ ] Aprobación del equipo

## DoD de Automatización

Un test/script está terminado cuando:

- [ ] Cobertura ≥ `COVERAGE_THRESHOLD` de `qa.config.md`
- [ ] Datos de prueba desacoplados del código
- [ ] Integrado al pipeline de CI (según `CI_TOOL` en `qa.config.md`)
- [ ] Trazabilidad con spec o HU documentada
- [ ] Revisión de código completada (por pares o agente revisor)

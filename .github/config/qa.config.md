---
# ASDD — Configuración de QA
# Modifica este archivo para personalizar el entorno de calidad de tu proyecto.
# Con solo editar este archivo, el QA Agent, los Test Engineers, los prompts
# y las instrucciones de tests se adaptan automáticamente al tooling y lenguaje especificados.
---

# Configuración de QA

## Lenguaje

| Variable | Valor | Opciones disponibles |
|----------|-------|----------------------|
| `TEST_LANGUAGE` | `java` | `python`, `javascript`, `typescript`, `java`, `go`, `ruby` |

## Herramienta de API Testing

| Variable | Valor | Opciones disponibles |
|----------|-------|----------------------|
| `API_TOOL` | `karate` | `karate`, `pytest-httpx`, `supertest`, `rest-assured`, `httpx`, `axios-mock-adapter`, `none` |


---

## Instrucciones para agentes que lean este archivo

Al leer este archivo DEBES:

1. **Adaptar todos los patrones de código** al `TEST_LANGUAGE` y `API_TOOL` configurados.
2. **Usar exclusivamente las herramientas especificadas** — no asumir frameworks por defecto.
<!-- 3. **Aplicar `COVERAGE_THRESHOLD`** como quality gate bloqueante en el DoD. -->
<!-- 4. **Generar artefactos y reportes** en el `REPORT_FORMAT` indicado. -->
<!-- 5. **Seguir la `UNIT_STRUCTURE`** para organizar los archivos de test. -->
<!-- 6. **Proponer configuración de CI** según `CI_TOOL` cuando sea relevante. -->

### Adaptaciones de código por herramienta
    
| Si `API_TOOL` es... | Patrón a usar |
|---------------------|----------------|
| `karate` | `gherkin`, `karate-config.js`, `logback-test.xml` |


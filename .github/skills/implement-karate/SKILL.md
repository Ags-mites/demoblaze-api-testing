---
name: implement-karate
description: Implementa tests de API Karate DSL para una feature. Requiere spec con status APPROVED en .github/specs/. Usa Java + Karate.
argument-hint: "<nombre-feature>"
---

# Implement Karate

## Prerequisitos
1. Leer spec: `.github/specs/<feature>.spec.md` — sección 2 (endpoints, modelos de respuesta)
2. Leer configuración QA: `.github/config/qa.config.md`
3. Leer paths: `.github/config/paths.config.md`

## Orden de implementación
```
karate-config.js → feature file → runner → ejecutar y verificar
```

## Estructura de archivos Karate

| Archivo | Ubicación | Descripción |
|---------|------------|-------------|
| **Feature file** | `karate-automation-exercise/src/test/java/<feature>.feature` | Escenarios BDD Gherkin |
| **Runner** | `karate-automation-exercise/src/test/java/com/automation/exercise/runner/<Feature>Runner.java` | Ejecutor JUnit5 |
| **Config** | `karate-automation-exercise/src/test/java/karate-config.js` | Configuración global (base URL, timeouts) |

## Patrones de implementación

### 1. Feature File (Gherkin)
```gherkin
Feature: Get Products List
  Validación del endpoint de lista de productos

  @happy-path
  Scenario: Obtener lista de productos con esquema válido
    Given url baseUrl + '/api/productsList'
    When method GET
    Then status 200
    And match response contains { responseCode: 200 }
    And match response.products == '#array'
    And match each response.products contains { id: '#number', name: '#string', price: '#number', brand: '#string', category: '#string' }

  @performance
  Scenario: Validar tiempo de respuesta
    Given url baseUrl + '/api/productsList'
    When method GET
    Then status 200
    * assert responseTime < 1000
```

### 2. Runner Java
```java
package com.automation.exercise.runner;

import com.intuit.karate.junit5.Karate;
import org.junit.jupiter.api.Test;

public class ProductsRunner {

    @Test
    public void testProducts() {
        Karate.run("classpath:products.feature").relativeTo(getClass());
    }
}
```

### 3. karate-config.js
```javascript
function fn() {
  karate.configure('readTimeout', 5000);
  karate.configure('connectTimeout', 5000);
  return {
    baseUrl: 'https://automationexercise.com'
  };
}
```

## Reglas de validación

Según la spec, validar:
- `responseCode`: 200
- `products`: array no vacío
- Cada producto: `id` (number), `name` (string), `price` (number), `brand` (string), `category` (string)
- Response time < 1000ms

## Ejecutar tests
```bash
cd karate-automation-exercise
mvn test -Dtest=ProductsRunner
```

## Restricciones
- Solo directorio `karate-automation-exercise/`. No modificar código fuente backend/frontend.
- Usar fuzzy matchers (`#number`, `#string`, `#array`) para evitar fragilidad en validaciones.
- No hardcodear datos sensibles — usar variables de entorno.

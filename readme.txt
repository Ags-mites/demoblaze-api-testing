================================================================================
INSTRUCCIONES DE EJECUCIÓN - DEMOBLAZE API TESTING
================================================================================

RESUMEN:
Este proyecto contiene una suite de tests automatizados para validar los 
servicios REST de registro (signup) y login de Demoblaze, implementados 
usando Karate DSL.

================================================================================
PRERREQUISITOS:
================================================================================

1. Java 11 o superior
   - Verificar: java -version
   
2. Maven 3.6 o superior
   - Descargar: https://maven.apache.org/download.cgi
   - Verificar: mvn -version
   
3. Git (opcional, para clonar el repositorio)
   - Descargar: https://git-scm.com/download

4. Internet disponible para conectar a https://api.demoblaze.com

================================================================================
INSTALACIÓN:
===============================================================================

Opción 1: Clonar el repositorio
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ git clone https://github.com/<username>/demoblaze-api-testing.git
$ cd demoblaze-api-testing

Opción 2: Descargar ZIP
~~~~~~~~~~~~~~~~~~~~~~~
- Descargar el proyecto en ZIP desde GitHub
- Extraer en una carpeta local
- Abrir terminal y navegar a la carpeta


================================================================================
ESTRUCTURA DEL PROYECTO:
================================================================================

demoblaze-api-testing/
├── pom.xml                          # Configuración Maven
├── src/test/java/
│   ├── karate-config.js             # Configuración global de Karate
│   ├── logback-test.xml             # Configuración de logging
│   ├── users/auth/
│   │   └── signup.feature           # Feature file con 4 escenarios Gherkin
│   └── com/demoblaze/test/runners/
│       └── SignupRunner.java        # JUnit5 runner
├── readme.txt                       # Este archivo
├── conclusiones.txt                 # Hallazgos y conclusiones
└── target/
    └── karate-reports/
        └── karate-summary.html      # Reportes HTML


================================================================================
CÓMO EJECUTAR LOS TESTS:
================================================================================

PASO 1: Navegar al directorio del proyecto
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ cd demoblaze-api-testing


PASO 2: Ejecutar todos los tests
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ mvn clean test -Dtest=SignupRunner

O con más verbosidad:
$ mvn clean test -Dtest=SignupRunner -X


PASO 3: Ver reportes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Después de ejecutar, abrir en navegador:
  - Reports: target/karate-reports/karate-summary.html
  - Timeline: target/karate-reports/karate-timeline.html
  - Tags: target/karate-reports/karate-tags.html


================================================================================
OPCIONES DE EJECUCIÓN:
================================================================================

Ejecutar solo tests de Signup:
  $ mvn test -Dtest=SignupRunner -Dkarate.include.tags=@signup

Ejecutar solo tests de Login:
  $ mvn test -Dtest=SignupRunner -Dkarate.include.tags=@login

Ejecutar solo tests críticos:
  $ mvn test -Dtest=SignupRunner -Dkarate.include.tags=@critical

Ejecutar con Base URL personalizada:
  $ mvn test -Dtest=SignupRunner -DbaseUrl=http://localhost:3000

Ejecutar con thread paralelos (más rápido):
  $ mvn test -Dtest=SignupRunner -Dkarate.env=parallel


================================================================================
DESCRIPCIÓN DE LOS CASOS DE PRUEBA:
================================================================================

CASO 1: Crear un nuevo usuario exitosamente
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- Endpoint: POST https://api.demoblaze.com/signup
- Payload: { username: "user@test.com", password: "TestPass123" }
- Validaciones:
  * HTTP Status Code 200
  * Response contiene responseCode
  * Response contiene message
- Resultado: ✓ PASS


CASO 2: Intentar crear usuario duplicado
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- Endpoint: POST https://api.demoblaze.com/signup
- Flujo:
  1. Crear primer usuario con email aleatorio
  2. Intentar crear nuevamente con el mismo email
- Validaciones:
  * Primer intento: HTTP 200
  * Segundo intento: HTTP 200 + message indicando duplicado
- Resultado: ✓ PASS


CASO 3: Login con credenciales válidas
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- Endpoint: POST https://api.demoblaze.com/login
- Payload: { username: "email@test.com", password: "password123" }
- Flujo:
  1. Crear usuario de prueba via signup
  2. Hacer login con credenciales correctas
- Validaciones:
  * HTTP Status Code 200
  * Response contiene responseCode
  * Response contiene message
  * Opcionalmente: userId, token
- Resultado: ✓ PASS


CASO 4: Login con credenciales incorrectas
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- Endpoint: POST https://api.demoblaze.com/login
- Payload: { username: "nonexistent@test.com", password: "WrongPassword" }
- Validaciones:
  * HTTP Status Code: 200, 401 ó 400
  * Response contiene message de error
- Resultado: ✓ PASS


================================================================================
INTERPRETAR LOS RESULTADOS:
================================================================================

✓ PASS (Verde)
  - El test ejecutó exitosamente
  - Todas las aserciones se cumplieron
  
✗ FAIL (Rojo)
  - El test falló
  - Una o más aserciones no se cumplieron
  - Ver mensaje de error en reportes HTML o terminal
  
⊘ SKIP (Amarillo)
  - El test fue omitido (tag exclusión o error previo)


================================================================================
TROUBLESHOOTING:
================================================================================

Error: "Connection refused"
  → Verificar que api.demoblaze.com está disponible
  → Verificar conectividad a internet
  → Revisar proxy/firewall

Error: "Tests run: 0"
  → Verificar que SignupRunner existe en src/test/java/com/demoblaze/test/runners/
  → Rebuild: mvn clean compile
  → Ejecutar: mvn clean test

Error: "HTTP 404"
  → Endpoint no disponible
  → Revisar Base URL en karate-config.js
  → Verificar estructura del API

Error: "Timeout"
  → API lenta
  → Aumentar timeout en karate-config.js (readTimeout, connectTimeout)
  → Ejecutar nuevamente


================================================================================
VER LOGS DETALLADOS:
================================================================================

Los logs se guardan en:
  target/karate-reports/karate-summary.json
  target/karate-reports/karate-timeline.html

Ver último test ejecutado:
  $ cat target/karate-reports/README.md


================================================================================
CONFIGURACIÓN PERSONALIZADA:
================================================================================

Modificar karate-config.js para cambiar:
  - Base URL de la API
  - Timeouts de conexión/lectura
  - Generación de datos de prueba
  - Variables globales compartidas

Ejemplo - cambiar Base URL permanentemente:
  Abrir: src/test/java/karate-config.js
  Buscar: baseUrl = 'https://api.demoblaze.com'
  Cambiar a: baseUrl = 'https://tu-api.com'


================================================================================
GENERAR REPORTES:
================================================================================

Los reportes se generan automáticamente en: target/karate-reports/

Archivos disponibles:
  - karate-summary.html    → Resumen visual de todos los tests
  - karate-timeline.html   → Timeline de ejecución
  - karate-tags.html       → Tests agrupados por tags
  - <feature>.html         → Reporte por feature file

Abrir reporte en navegador:
  $ open target/karate-reports/karate-summary.html  # macOS
  $ xdg-open target/karate-reports/karate-summary.html  # Linux
  $ start target/karate-reports/karate-summary.html  # Windows


================================================================================
LIMPIAR PROYECTO:
================================================================================

Limpiar compilación:
  $ mvn clean

Limpiar y compilar:
  $ mvn clean compile

Limpiar y ejecutar tests:
  $ mvn clean test

Limpiar todo (incluye target/):
  $ mvn clean


================================================================================
ESTRUCTURA DE DATOS DE PRUEBA:
================================================================================

Email generados dinámicamente:
  - Formato: testuser<timestamp><random>@test.com
  - Ejemplo: testuser1712599234567891@test.com
  
Passwords:
  - TestPass123 (signup)
  - ValidPass123 (login)
  - WrongPassword123 (invalido)


================================================================================
TECNOLOGÍAS UTILIZADAS:
================================================================================

- Karate DSL 1.4.1    → Framework para API testing (BDD/Gherkin)
- JUnit5              → Test runner
- Maven 3.11.0        → Build tool
- Java 11+            → Lenguaje de programación
- Gherkin             → Sintaxis BDD


================================================================================
REFERENCIAS Y ENLACES:
================================================================================

- Karate Docs: https://github.com/intuit/karate
- Gherkin/BDD: https://cucumber.io/docs/gherkin/
- Maven: https://maven.apache.org/
- API Demoblaze: https://www.demoblaze.com/


================================================================================
SOPORTE Y AYUDA:
================================================================================

Para reportar problemas o propuestas de mejora:
1. Crear un Issue en GitHub
2. Describir el problema claramente
3. Incluir output de ejecución si es posible
4. Mencionar OS, Java version, Maven version


================================================================================
LICENCIA:
================================================================================

Este proyecto está disponible bajo licencia MIT.
Ver archivo LICENSE.txt (si existe) para más detalles.


================================================================================
ÚLTIMO AUTOR:
================================================================================

Especificación ASDD Workflow
Generado: 2026-04-08
================================================================================

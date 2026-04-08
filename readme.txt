INSTRUCCIONES DE EJECUCIÓN 

RESUMEN:
Este proyecto contiene una suite de tests automatizados para validar los servicios REST de registro (signup) y login de Demoblaze, implementados usando Karate DSL.

Cuenta con 3 runners disponibles:
  1. AllTestsRunner - Ejecuta TODOS los tests (Signup + Login) - RECOMENDADO
  2. SignupRunner - Ejecuta solo tests de Signup
  3. LoginRunner - Ejecuta solo tests de Login

PRERREQUISITOS:

1. Java 11 o superior
   - Verificar: java -version
   
2. Maven 3.6 o superior
   - Descargar: https://maven.apache.org/download.cgi
   - Verificar: mvn -version
   
3. Git (opcional, para clonar el repositorio)
   - Descargar: https://git-scm.com/download

4. Internet disponible para conectar a https://api.demoblaze.com

INSTALACIÓN:

Opción 1: Clonar el repositorio

$ git clone https://github.com/<username>/demoblaze-api-testing.git
$ cd demoblaze-api-testing

Opción 2: Descargar ZIP

- Descargar el proyecto en ZIP desde GitHub
- Extraer en una carpeta local
- Abrir terminal y navegar a la carpeta


ESTRUCTURA DEL PROYECTO:

demoblaze-api-testing/
├── pom.xml                          # Configuración Maven
├── src/test/java/
│   ├── karate-config.js             # Configuración global de Karate
│   ├── logback-test.xml             # Configuración de logging
│   ├── users/auth/
│   │   ├── signup.feature           # Feature file con 4 escenarios (Signup)
│   │   └── login.feature            # Feature file con 4 escenarios (Login)
│   └── com/demoblaze/test/runners/
│       ├── AllTestsRunner.java      # JUnit5 runner - TODOS LOS TESTS
│       ├── SignupRunner.java        # JUnit5 runner - Solo Signup
│       └── LoginRunner.java         # JUnit5 runner - Solo Login
├── readme.txt                       # Este archivo
├── conclusiones.txt                 # Hallazgos y conclusiones
├── RUNNERS_COMPARISON.txt           # Comparativa de los 3 runners
├── ALLESTESRUNNER_GUIDE.txt         # Guía de AllTestsRunner
└── target/
    └── karate-reports/
        └── karate-summary.html      # Reportes HTML


CÓMO EJECUTAR LOS TESTS:

PASO 1: Navegar al directorio del proyecto

$ cd demoblaze-api-testing


PASO 2: Elegir qué tests ejecutar

OPCIÓN 1: Ejecutar TODOS los tests 
   $ mvn clean test -Dtest=AllTestsRunner
   → Ejecuta: Signup (4 tests) + Login (4 tests) = 8 tests
   → Tiempo: ~11 segundos
   → Ideal para: CI/CD, validación completa

OPCIÓN 2: Ejecutar solo Signup tests
   $ mvn clean test -Dtest=SignupRunner
   → Ejecuta: 4 tests de Signup
   → Tiempo: ~11 segundos
   → Ideal para: Debugging de Signup

OPCIÓN 3: Ejecutar solo Login tests
   $ mvn clean test -Dtest=LoginRunner
   → Ejecuta: 4 tests de Login
   → Tiempo: ~4 segundos
   → Ideal para: Debugging de Login

Con más verbosidad (agregar -X):
$ mvn clean test -Dtest=AllTestsRunner -X


PASO 3: Ver reportes

Después de ejecutar, abrir en navegador:
  - Reports: target/karate-reports/karate-summary.html
  - Timeline: target/karate-reports/karate-timeline.html
  - Tags: target/karate-reports/karate-tags.html


OPCIONES DE EJECUCIÓN AVANZADAS:

EJECUTAR CON FILTROS DE TAGS:

Ejecutar solo tests críticos (con AllTestsRunner):
  $ mvn clean test -Dtest=AllTestsRunner -Dkarate.include.tags=@critical
  → Ejecuta: 8 tests (todos tienen @critical)

Ejecutar solo tests de Signup (con AllTestsRunner):
  $ mvn clean test -Dtest=AllTestsRunner -Dkarate.include.tags=@signup
  → Ejecuta: 4 tests de Signup

Ejecutar solo tests de Login (con AllTestsRunner):
  $ mvn clean test -Dtest=AllTestsRunner -Dkarate.include.tags=@login
  → Ejecuta: 4 tests de Login

Ejecutar solo E2E (Flujo Signup → Login):
  $ mvn clean test -Dtest=AllTestsRunner -Dkarate.include.tags=@e2e
  → Ejecuta: 1 test (CASO 3.4)


EJECUTAR CON CONFIGURACIÓN PERSONALIZADA:

Ejecutar con Base URL personalizada:
  $ mvn clean test -Dtest=AllTestsRunner -DbaseUrl=http://localhost:3000

Ejecutar con timeout personalizado:
  $ mvn clean test -Dtest=AllTestsRunner -DreadTimeout=10000

Ejecutar con threads paralelos:
  $ mvn clean test -Dtest=AllTestsRunner -Dkarate.env=parallel


REFERENCIA RÁPIDA:

Todos los tests (8/8):
  $ mvn clean test -Dtest=AllTestsRunner

Solo Signup (4/4):
  $ mvn clean test -Dtest=SignupRunner

Solo Login (4/4):
  $ mvn clean test -Dtest=LoginRunner

Ver runners disponibles:
  Ver archivo: RUNNERS_COMPARISON.txt


DESCRIPCIÓN DE LOS CASOS DE PRUEBA:

TESTS DE SIGNUP:

CASO 1: Crear un nuevo usuario exitosamente
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- Endpoint: POST https://api.demoblaze.com/signup
- Payload: { username: "email@test.com", password: "TestPass123" }
- Validaciones:
  * HTTP Status Code 200
  * Response contiene responseCode
  * Response contiene message
- Email generado dinámicamente para garantizar unicidad
- Resultado: ✓ PASS


CASO 2: Intentar crear usuario duplicado
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- Endpoint: POST https://api.demoblaze.com/signup
- Flujo:
  1. Crear primer usuario con email aleatorio
  2. Intentar crear nuevamente con el mismo email
- Validaciones:
  * Primer intento: HTTP 200
  * Segundo intento: HTTP 200 + message "This user already exists."
- Resultado: ✓ PASS


TESTS DE LOGIN:

CASO 3.1: Login con credenciales válidas
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- Endpoint: POST https://api.demoblaze.com/login
- Flujo:
  1. Crear usuario de prueba via Signup
  2. Hacer login con credenciales correctas
- Payload: { username: "email@test.com", password: "ValidPass123" }
- Validaciones:
  * HTTP Status Code 200
  * Response: message "Login successful."
  * Opcionalmente: userId, token
- Resultado: ✓ PASS


CASO 3.2: Login rechazado por password incorrecto
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- Endpoint: POST https://api.demoblaze.com/login
- Flujo:
  1. Crear usuario con password correcto
  2. Intentar login con password incorrecto
- Payload: { username: "email@test.com", password: "WrongPassword123" }
- Validaciones:
  * HTTP Status Code 200 o 401
  * Response: message "Wrong password."
  * No se inicia sesión
- Resultado: ✓ PASS


CASO 3.3: Login rechazado porque usuario no existe
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- Endpoint: POST https://api.demoblaze.com/login
- Payload: { username: "nonexistent@test.com", password: "SomePassword123" }
- Validaciones:
  * HTTP Status Code 200 o 400
  * Response: message "User does not exist."
  * No se inicia sesión
- Resultado: ✓ PASS


CASO 3.4: Flujo E2E - Signup → Login
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- Flujo completo:
  1. Crear usuario dinámicamente (Signup)
  2. Hacer login con credenciales del usuario creado (Login)
- Validaciones:
  * Signup exitoso: HTTP 200
  * Login exitoso: HTTP 200 + message "Login successful."
  * Credenciales reutilizadas sin hardcodeo
- Demuestra: Integración completa Signup → Login
- Resultado: ✓ PASS


TROUBLESHOOTING:

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


CONFIGURACIÓN PERSONALIZADA:

Modificar karate-config.js para cambiar:
  - Base URL de la API
  - Timeouts de conexión/lectura
  - Generación de datos de prueba
  - Variables globales compartidas

Ejemplo - cambiar Base URL permanentemente:
  Abrir: src/test/java/karate-config.js
  Buscar: baseUrl = 'https://api.demoblaze.com'
  Cambiar a: baseUrl = 'https://tu-api.com'


GENERAR REPORTES:

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


LIMPIAR PROYECTO:

Limpiar compilación:
  $ mvn clean

Limpiar y compilar:
  $ mvn clean compile

Limpiar y ejecutar tests:
  $ mvn clean test

Limpiar todo (incluye target/):
  $ mvn clean


ESTRUCTURA DE DATOS DE PRUEBA:

Email generados dinámicamente:
  - Formato: testuser<timestamp><random>@test.com
  - Ejemplo: testuser1712599234567891@test.com
  
Passwords:
  - TestPass123 (signup)
  - ValidPass123 (login)
  - WrongPassword123 (invalido)


TECNOLOGÍAS UTILIZADAS:

- Karate DSL 1.4.1    → Framework para API testing (BDD/Gherkin)
- JUnit5              → Test runner
- Maven 3.11.0        → Build tool
- Java 11+            → Lenguaje de programación
- Gherkin             → Sintaxis BDD

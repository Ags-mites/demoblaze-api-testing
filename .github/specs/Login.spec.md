---
id: SPEC-002
status: APPROVED
feature: login
created: 2026-04-08
updated: 2026-04-08
author: spec-generator
version: "1.0"
related-specs: ["SPEC-001"]
---

# Spec: Autenticación de Usuarios (Login)

> **Estado:** `DRAFT` → aprobar con `status: APPROVED` antes de iniciar implementación.
> **Ciclo de vida:** DRAFT → APPROVED → IN_PROGRESS → IMPLEMENTED → DEPRECATED

---

## 1. REQUERIMIENTOS

### Descripción
Validar el endpoint de autenticación (`/login`) de la API Demoblaze para garantizar que solo los usuarios legítimos con credenciales válidas puedan acceder, mientras que los intentos fraudulentos (usuario no existent o password incorrecto) sean rechazados. Incluye validación de contrato de respuesta y flujo E2E de Signup → Login.

### Requerimiento de Negocio
```
Como:        Arquitecto de Seguridad
Quiero:      validar el endpoint de autenticación (/login)
Para:        asegurar que solo los usuarios legítimos puedan acceder
             y que los intentos fraudulentos sean bloqueados
```

### Historias de Usuario

#### HU-02: Autenticación de Usuario Existente

```
Como:        Usuario no autenticado
Quiero:      iniciar sesión con mis credenciales válidas (username y password)
Para:        acceder a la plataforma y mis datos personales en Demoblaze

Prioridad:   Alta
Estimación:  S
Dependencias: HU-01 (usuario debe existir via Signup)
Capa:        Backend (API)
```

#### Criterios de Aceptación — HU-02

**Happy Path — Login Exitoso**
```gherkin
CRITERIO-2.1: Autenticación exitosa con credenciales válidas y existentes
  Dado que:   un usuario con username "testuser@example.com" y password "ValidPass123" 
              ya existe en la base de datos (creado via Signup)
  Cuando:     envío un POST a /api/v1/auth/login con las credenciales correctas
              en el payload { "username": "testuser@example.com", "password": "ValidPass123" }
  Entonces:   el sistema responde con Status Code 200 OK
              y retorna un objeto JSON con { "message": "Login successful." }
              y opcionalmente retorna "userId" y/o "token" si están implementados
              y no se registran intentos fallidos en la auditoría
```

**Error Path — Password Incorrecto**
```gherkin
CRITERIO-2.2: Rechazo cuando password es incorrecto
  Dado que:   un usuario con username "testuser@example.com" existe
              con password correcto "ValidPass123"
  Cuando:     intento hacer login con el mismo username pero password "WrongPassword123"
  Entonces:   el sistema responde con Status Code 200 OK o 401 Unauthorized
              y retorna exactamente el mensaje: "Wrong password."
              y NO se inicia sesión (no se retorna token/userId válido)
              y se registra el intento fallido para auditoría de seguridad
```

**Error Path — Usuario No Existe**
```gherkin
CRITERIO-2.3: Rechazo cuando usuario no existe
  Dado que:   no existe ningún usuario con username "nonexistent@example.com"
              en la base de datos
  Cuando:     intento hacer login con username "nonexistent@example.com"
              y un password cualquiera "SomePassword123"
  Entonces:   el sistema responde con Status Code 200 OK o 400/401
              y retorna exactamente el mensaje: "User does not exist."
              y NO se inicia sesión
              y se registra el intento fallido para auditoría de seguridad
```

**Escenario E2E — Flujo Signup → Login**
```gherkin
CRITERIO-2.4: Consumir dinámicamente credenciales del Signup en mismo test suite
  Dado que:   ejecuto el test suite en orden: Signup → Login
  Y:          el test de Signup genera un usuario dinámico con email 
              "testuser<timestamp><random>@test.com"
              y password "TestPass123"
  Cuando:     el test de Login recibe las credenciales creadas dinámicamente
              y las utiliza para hacer login (sin hardcodear valores)
  Entonces:   el test de Login de happy path (CRITERIO-2.1) debe pasar
              demostrando un flujo E2E completo
```

**Validación de Contrato**
```gherkin
CRITERIO-2.5: Response body y headers cumplen con esquema esperado
  Dado que:   el endpoint POST /api/v1/auth/login responde
  Cuando:     valido la estructura del response (exitoso o error)
  Entonces:   el response.header["Content-Type"] contiene "application/json"
              y el response.body es un objeto JSON válido
              y el response.body contiene la clave "message" de tipo string
              y en caso de éxito, puede contener "userId" y "token" (opcionales)
```

### Reglas de Negocio

1. **Validación de Credenciales**
   - Campo `username` es obligatorio, no puede estar vacío
   - Campo `password` es obligatorio, no puede estar vacío
   - El lookup es **case-sensitive** (según comportamiento actual de la API)
   - Ambos campos deben viajar en el request body como JSON

2. **Diferenciación de Errores**
   - Si el usuario NO existe → mensaje: `"User does not exist."`
   - Si el usuario existe pero password es incorrecto → mensaje: `"Wrong password."`
   - Diferenciación clara para facilitar debugging cliente y auditoría

3. **Respuesta API**
   - Código HTTP 200 OK para happy path
   - Códigos HTTP 200, 401 o 400 para error path (según implementación actual)
   - El body siempre es JSON con clave `message` obligatoria
   - En happy path, opcionalmente incluye `userId` y `token` si están implementados
   - Content-Type siempre `application/json; charset=utf-8`

4. **Auditoría de Seguridad**
   - Registrar intentos fallidos de login (para detección de brute force futuro)
   - Registrar logins exitosos (para auditoría de acceso)
   - No exponer en response si el usuario existe o no (usar mensajes genéricos)
   - NO retornar información sensible (password, datos personales) en response

5. **Performance**
   - Umbral máximo de respuesta: 500ms
   - Aplicado a operaciones de lookup (búsqueda de usuario) y validación de password

6. **Dependencia con Signup**
   - El usuario debe existir en la base de datos (creado via Signup HU-01)
   - El password debe coincidir exactamente con el almacenado
   - Si el sistema soporta E2E, los tests deben ejecutarse en orden: Signup → Login

---

## 2. DISEÑO

### Modelos de Datos

#### Entidades afectadas

| Entidad | Almacén | Cambios | Descripción |
|---------|---------|---------|-------------|
| `User` | colección `users` | existente (usada) | Documento de usuario creado en Signup |
| `LoginAttempt` | colección `login_attempts` | nueva (opcional) | Registro de intentos de login para auditoría |

#### Campos del modelo User (existente, usados en Login)

| Campo | Tipo | Obligatorio | Validación | Descripción |
|-------|------|-------------|------------|-------------|
| `_id` | ObjectId | sí | auto-generado | ID de MongoDB |
| `username` | string | sí | único | Nombre de usuario para login |
| `password` | string | sí | min 6 chars | Credencial de autenticación |
| `created_at` | timestamp | sí | auto-generado (ISO8601 UTC) | Timestamp de creación |

#### Campos del modelo LoginAttempt (opcional, para auditoría)

| Campo | Tipo | Obligatorio | Validación | Descripción |
|-------|------|-------------|------------|-------------|
| `_id` | ObjectId | sí | auto-generado | ID del registro |
| `username` | string | sí | - | Username usado en intento |
| `success` | boolean | sí | - | true si fue exitoso, false si falló |
| `reason` | string | no | enum: user_not_found, wrong_password, success | Razón del resultado |
| `ip_address` | string | no | - | IP del cliente (si se captura) |
| `timestamp` | timestamp | sí | auto-generado (ISO8601 UTC) | Cuando ocurrió el intento |

#### Índices / Constraints

| Índice | Campo(s) | Tipo | Justificación |
|--------|----------|------|---------------|
| `username_index` | `username` | Regular | Búsqueda rápida en Signup (ya existe) |
| `loginattempt_username_index` | `username` | Regular | Búsqueda de intentos por usuario |
| `loginattempt_timestamp_index` | `timestamp` | Regular | Ayuda con queries de rango temporal (auditoría) |

### API Endpoints

#### POST /api/v1/auth/login

- **Descripción**: Autentica un usuario existente y retorna confirmación de acceso
- **Auth requerida**: No (el endpoint mismo es el que autentica)
- **Request Body**:
  ```json
  {
    "username": "string (obligatorio, 3-50 chars)",
    "password": "string (obligatorio, min 6 chars)"
  }
  ```

- **Response 200 — Login Exitoso**:
  ```json
  {
    "message": "Login successful.",
    "userId": "uuid o ObjectId (opcional)",
    "token": "JWT o Bearer token (opcional)"
  }
  ```
  Notas:
  - El endpoint retorna 200 para ambos casos: éxito y error (según API actual)
  - `userId` y `token` son opcionales dependiendo de la implementación
  - Esta es la respuesta feliz

- **Response 200 — Error: Usuario No Existe**:
  ```json
  {
    "message": "User does not exist."
  }
  ```

- **Response 200 — Error: Password Incorrecto**:
  ```json
  {
    "message": "Wrong password."
  }
  ```

- **Response 401 (alternativo, si se implementa)**:
  ```json
  {
    "message": "Wrong password."
  }
  ```
  O:
  ```json
  {
    "message": "User does not exist."
  }
  ```

- **Response 400 (alternativo, si se implementa — datos faltantes)**:
  ```json
  {
    "message": "Missing username or password."
  }
  ```

#### Códigos HTTP Esperados

| Código | Caso | Mensaje esperado |
|--------|------|-----------------|
| 200 | Login exitoso | `"Login successful."` |
| 200 | Usuario no existe | `"User does not exist."` |
| 200 | Password incorrecto | `"Wrong password."` |
| 400 | Datos en request inválidos o faltantes | `"Missing username or password."` o similar |
| 401 | Alternativa: password incorrecto o usuario no existe | Depende de implementación |

### Diseño de Tests (Karate DSL)

#### Feature file: `src/test/java/users/auth/login.feature`

Estructura esperada:

```gherkin
Feature: Demoblaze API - Login Testing
  
  Background:
    * def baseUrl = 'https://api.demoblaze.com'
    * def loginPath = '/login'
    * def signupPath = '/signup'
    * def getRandomEmail = function() { ... }
    
  Scenario: CASO-3.1 - Login exitoso con credenciales válidas
    # Prerequisito: crear usuario via Signup
    # Ejecutar: POST /signup con username y password
    # Validar: response status 200, message success
    # Ejecutar: POST /login con mismas credenciales
    # Validar: response status 200, message "Login successful."
    
  Scenario: CASO-3.2 - Login rechazado: password incorrecto
    # Prerequisito: crear usuario via Signup
    # Ejecutar: POST /login con username correcto pero password incorrecto
    # Validar: response status 200 o 401, message "Wrong password."
    
  Scenario: CASO-3.3 - Login rechazado: usuario no existe
    # Ejecutar: POST /login con username inexistente
    # Validar: response status 200 o 400, message "User does not exist."
```

### Arquitectura y Dependencias

- **Paquetes nuevos requeridos**: Ninguno (Karate DSL ya instalado en Signup)
- **Reutilizar del spec anterior**: 
  - `karate-config.js` (global baseUrl y helpers)
  - `logback-test.xml` (logging)
  - `SignupRunner.java` (puede extenderse o crear `LoginRunner.java`)
  
- **Servicios externos**: Ninguno adicional
  - Usa la misma API Demoblaze: `https://api.demoblaze.com`
  
- **Impacto en arquitectura existente**: 
  - Agregar feature file `login.feature` en paralelo a `signup.feature`
  - Crear runner `LoginRunner.java` o extender `SignupRunner.java` para incluir ambos features
  - Los tests pueden ejecutarse en orden (Signup primero, luego Login) si se requiere E2E

### Notas de Implementación

> **Diseño actual de Demoblaze (HTTP 200 para errores):**
> La API Demoblaze retorna HTTP 200 para ambos casos (éxito y error de login).
> Esto NO es RESTful estándar (debería ser 401 para error), pero es el contrato actual.
> Los tests deben validar el **mensaje en response body**, no solo el status code.

> **Diferenciación cliente-servidor:**
> El cliente (tests o UI) debe:
> 1. Verificar `response.message === "Login successful."` para éxito
> 2. Diferenciar entre `"User does not exist."` y `"Wrong password."` para mejorar UX

> **E2E en Karate:**
> Karate mantiene variables en contexto durante los scenarios de un feature file.
> Se pueden reutilizar las credenciales del Signup en el Login si está en mismo feature
> o si se cargan en Background.

> **Rate limiting (futuro):**
> Aunque no está requerido en esta spec, se recomienda implementar throttling
> por username después de 5 intentos fallidos en 15 minutos (OWASP).

---

## 3. LISTA DE TAREAS

> Checklist accionable para todos los agentes. Marcar cada ítem (`[x]`) al completarlo.
> El Orchestrator monitorea este checklist para determinar el progreso.

### Backend

#### Implementación (Karate DSL — No aplica backend tradicional)
- [ ] Verificar que el endpoint POST `/login` es accesible en `https://api.demoblaze.com/login`
- [ ] Documentar contrato exacto: códigos HTTP, estructura JSON response, mensajes

#### Tests Backend / Karate DSL
- [ ] Crear feature file `src/test/java/users/auth/login.feature` con 4 scenarios
- [ ] Implementar CASO-3.1: Login exitoso con credenciales válidas
  - [ ] Setup: crear usuario via Signup (CASO-1)
  - [ ] POST `login` con credenciales correctas
  - [ ] Validar: status 200, message "Login successful."
  - [ ] Tag: `@login @valid-credentials @critical`
  
- [ ] Implementar CASO-3.2: Password incorrecto
  - [ ] Setup: crear usuario via Signup
  - [ ] POST `login` con password incorrecto
  - [ ] Validar: status 200 o 401, message "Wrong password."
  - [ ] Tag: `@login @invalid-password @critical`
  
- [ ] Implementar CASO-3.3: Usuario no existe
  - [ ] POST `login` con username inexistente
  - [ ] Validar: status 200 o 400, message "User does not exist."
  - [ ] Tag: `@login @user-not-found @critical`
  
- [ ] Implementar E2E (CASO-3.4): Flujo Signup → Login
  - [ ] Ejecutar Signup, capturar credenciales dinámicamente
  - [ ] Reutilizar credenciales en Login
  - [ ] Validar flujo completo sin hardcodeo
  - [ ] Tag: `@login @e2e @critical`

- [ ] Crear o extender runner: `src/test/java/com/demoblaze/test/runners/LoginRunner.java`
  - [ ] Ejecutar feature file `login.feature`
  - [ ] Soportar tags: `-Dkarate.include.tags=@login`

- [ ] Validar contrato API (CRITERIO-2.5)
  - [ ] Validar Content-Type header
  - [ ] Validar estructura JSON de response
  - [ ] Validar presencia de clave `message` en todos los casos

### Frontend
- [ ] No aplica para este proyecto de pruebas de API pura

### QA / Validación
- [ ] Ejecutar suite completa: `mvn clean test -Dtest=LoginRunner`
- [ ] Validar: todos 4 casos pasan
- [ ] Revisar HTML reports en `target/karate-reports/login_feature.html`
- [ ] Ejecutar E2E: `mvn clean test -Dtest=SignupRunner,LoginRunner`
  - [ ] Validar orden de ejecución: Signup primero, Login después
  - [ ] Validar que datos se reutiliza correctamente
- [ ] Ejecutar skill `/gherkin-case-generator` → documentar escenarios Gherkin
- [ ] Ejecutar skill `/risk-identifier` → clasificación ASD de riesgos de Login
- [ ] Documentar hallazgos en `conclusiones-login.txt` después de tests exitosos
- [ ] Actualizar estado spec: `status: APPROVED` (si el usuario lo valida)

---

## 4. DEPENDENCIAS Y RIESGOS

### Dependencias
- **SPEC-001 (Signup)**: Login depende de Signup. El usuario debe existir antes de poder hacer login.
- **Instancia de API**: API Demoblaze debe estar operativa en `https://api.demoblaze.com`
- **Test data**: Tests generan usuarios dinámicos, no hay datos hardcodeados

### Riesgos Identificados (Análisis ASD)

| Riesgo | Nivel | Descripción | Mitigación |
|--------|-------|-------------|-----------|
| HTTP 200 para errores | Bajo | API no estándar (debería ser 401/400) | Validar message body, no solo status code |
| Race condition E2E | Bajo | Si Signup y Login se ejecutan en paralelo | Usar tags para ejecutar en orden: `@signup` luego `@login` |
| Username case-sensitivity | Bajo | Lookup es case-sensitive | Documentar y validar en tests |
| Rate limiting ausente (futuro) | Medio | Sin protección contra brute force | Implementar en próxima fase; registrar intentos en LoginAttempt |
| Token/userId ausente (opcional) | Bajo | Spec indica como opcional | Validar con `||` en Karate para valor default |

---

## 5. APROBACIÓN Y PRÓXIMOS PASOS

**Status actual**: `DRAFT`

**Para aprobar esta spec:**
1. [ ] El usuario revisa los 4 criterios de aceptación
2. [ ] Valida que alinean con requisito en `.github/requirements/Login.md`
3. [ ] Confirma que está de acuerdo con el diseño
4. [ ] Comenta cualquier cambio necesario

**Una vez aprobada (`status: APPROVED`):**
- [ ] Backend Developer (Karate): Implementa tests en `login.feature` + `LoginRunner.java`
- [ ] QA Agent: Genera escenarios Gherkin detallados, riesgos clasificados
- [ ] Orchestrator: Ejecuta suite completa, valida E2E

---

## Diccionario de Términos (referencia copilot-instructions.md)

| Término | Definición |
|---------|-----------|
| **Usuario** (`user`) | Persona registrada en el sistema mediante Signup |
| **Token** (`token`) | Credencial de autorización (JWT o similar) retornada tras login exitoso |
| **UID** (`_id`) | Identificador único de MongoDB (ObjectId) |
| **E2E** | End-to-End: Flujo completo Signup → Login sin pasos intermedios |
| **caso / scenario** | Prueba específica que valida un criterio de aceptación |

---


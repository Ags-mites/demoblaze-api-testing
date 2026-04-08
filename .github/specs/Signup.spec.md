---
id: SPEC-001
status: APPROVED
feature: signup
created: 2026-04-08
updated: 2026-04-08
author: spec-generator
version: "1.0"
related-specs: []
---

# Spec: Registro de Nuevos Usuarios (Signup)

> **Estado:** `DRAFT` → aprobar con `status: APPROVED` antes de iniciar implementación.
> **Ciclo de vida:** DRAFT → APPROVED → IN_PROGRESS → IMPLEMENTED → DEPRECATED

---

## 1. REQUERIMIENTOS

### Descripción
Validar el endpoint de registro (`/signup`) de la API Demoblaze para garantizar que los nuevos usuarios puedan darse de alta correctamente con credenciales únicas, El sistema debe rechazar intentos de registro duplicados y cumplir con validaciones de contrato y performance baseline.

### Requerimiento de Negocio
```
Como:        Arquitecto de Seguridad
Quiero:      validar el endpoint de registro (/signup)
Para:        garantizar que los nuevos usuarios puedan darse de alta correctamente 
             y que el sistema rechace duplicados
```

### Historias de Usuario

#### HU-01: Registro de Usuario Nuevo

```
Como:        Usuario no autenticado
Quiero:      registrarme con un username único y password
Para:        acceder a la plataforma Demoblaze

Prioridad:   Alta
Estimación:  S
Dependencias: Ninguna
Capa:        Backend (API)
```

#### Criterios de Aceptación — HU-01

**Happy Path**
```gherkin
CRITERIO-1.1: Registro exitoso con credenciales válidas y username único
  Dado que:   el endpoint POST /api/v1/auth/signup está disponible
  Cuando:     envío un payload con username dinámico único y password válido
  Entonces:   el sistema responde con Status Code 200 OK
              y retorna un objeto con { "message": "User created successfully." }
              y el usuario queda registrado en la base de datos
```

**Error Path — Duplicados**
```gherkin
CRITERIO-1.2: Rechazo de registro con username duplicado
  Dado que:   un usuario con username "existinguser" ya existe en la base de datos
  Cuando:     intento registrar un nuevo usuario con el mismo username "existinguser"
  Entonces:   el sistema responde con Status Code 200 OK (según contrato API actual)
              y retorna exactamente el mensaje: "This user already exists."
              y NO se crea un nuevo usuario en la base de datos
```

**Validación de Contrato**
```gherkin
CRITERIO-1.3: Response body y headers cumplen con esquema esperado
  Dado que:   el endpoint POST /api/v1/auth/signup responde
  Cuando:     valido la estructura del response
  Entonces:   el response.header["Content-Type"] contiene "application/json"
              y el response.body es un objeto JSON válido
              y el response.body contiene la clave "message" de tipo string
```

**Performance Baseline**
```gherkin
CRITERIO-1.4: Response Time no excede 500ms
  Dado que:   el endpoint POST /api/v1/auth/signup está disponible
  Cuando:     envío una solicitud de registro válida
  Entonces:   el Response Time (desde req hasta resp) no debe exceder 500ms
              (medido al menos 10 veces consecutivas, promedios)
```

### Reglas de Negocio

1. **Validación de Username**
   - Campo `username` es obligatorio, no puede estar vacío
   - Debe tener entre 3 y 50 caracteres
   - Debe ser único en la colección `users`
   - Caracteres permitidos: alfanuméricos, guiones y guiones bajos

2. **Validación de Password**
   - Campo `password` es obligatorio, no puede estar vacío
   - Debe tener mínimo 6 caracteres
   - Sin restricciones de carácter especial (el cliente decide el formato)

3. **Integridad de Datos**
   - No se permiten registros duplicados por username
   - El lookup de duplicado es **case-sensitive** (según comportamiento actual de la API)
   - Si el username ya existe, el sistema retorna el mensaje exacto: `"This user already exists."`

4. **Respuesta API**
   - Código HTTP 200 OK para ambos casos (éxito y duplicado)
   - El body siempre es JSON con clave `message`
   - Content-Type siempre `application/json; charset=utf-8`

5. **Performance**
   - Umbral máximo de respuesta: 500ms
   - Aplicado a operaciones de lookup (búsqueda de duplicados) y creación

---

## 2. DISEÑO

### Modelos de Datos

#### Entidades afectadas

| Entidad | Almacén | Cambios | Descripción |
|---------|---------|---------|-------------|
| `User` | colección `users` | nueva | Documento de usuario con credenciales básicas |

#### Campos del modelo User

| Campo | Tipo | Obligatorio | Validación | Descripción |
|-------|------|-------------|------------|-------------|
| `_id` | ObjectId | sí | auto-generado | ID de MongoDB |
| `username` | string | sí | 3-50 chars, único, alphanum + `-_` | Nombre de usuario único |
| `password` | string | sí | min 6 chars | Password hasheado (si aplica) o texto plano según API actual |
| `created_at` | timestamp | sí | auto-generado (ISO8601 UTC) | Timestamp de creación |
| `updated_at` | timestamp | sí | auto-generado (ISO8601 UTC) | Timestamp de última actualización |

#### Índices / Constraints

| Índice | Campo(s) | Tipo | Justificación |
|--------|----------|------|---------------|
| `username_unique` | `username` | Unique | Garantizar unicidad de username |
| `created_at_index` | `created_at` | Regular | Búsquedas por fecha de creación |

### API Endpoints

#### POST /api/v1/auth/signup

- **Descripción**: Registra un nuevo usuario en la plataforma
- **Auth requerida**: No
- **Request Body**:
  ```json
  {
    "username": "string (3-50 chars, required, unique)",
    "password": "string (min 6 chars, required)"
  }
  ```

- **Response 200 — Success**:
  ```json
  {
    "message": "User created successfully."
  }
  ```

- **Response 200 — Duplicate (según contrato API actual)**:
  ```json
  {
    "message": "This user already exists."
  }
  ```

- **Response 400 — Validación**:
  ```json
  {
    "message": "Missing or invalid parameters: [campo]"
  }
  ```
  - Username vacío, muy corto, muy largo o caracteres no permitidos
  - Password vacío o menos de 6 caracteres
  - Username o password omitido del request

- **Response 500 — Error del Servidor**:
  ```json
  {
    "message": "Something went wrong."
  }
  ```

#### Notas Técnicas del Endpoint

- **Time Out**: máximo 500ms de respuesta
- **Content-Type**: `application/json; charset=utf-8`
- **Método**: POST exclusivamente
- **Ruta base**: `/api/v1/auth/signup` (o `/api/signup` según estructura actual)

### Diseño Frontend

**Nota**: Este requerimiento es validación backend de API. Frontend es responsabilidad de feature separada "Login/Signup UI", si aplica.

- Formulario de registro será responsabilidad de HU separada
- El consumer de este endpoint será un componente de sign-up form que valida localmente y llama a `POST /api/v1/auth/signup`

### Arquitectura y Dependencias

- **Paquetes nuevos**: Ninguno (usar existente stack FastAPI + MongoDB)
- **Servicios externos**: Firebase Auth (futuro) — por ahora solo validación local
- **Impacto en punto de entrada**: Registrar router `/auth/signup` en `app.py` o equivalent

### Notas de Implementación

1. **Duplicado con Status 200**: La API actual retorna 200 OK incluso cuando el usuario ya existe (no 409 Conflict). Esto debe reflejarse en los tests.
2. **Password Hashing**: Verificar si la API debe hashear el password. Spec asume almacenamiento actual (a validar).
3. **Performance**: El lookup de username debe usar índice DB único para mantener < 500ms.
4. **Validación**: Lado servidor; no asumir validación cliente.
5. **Caracteres Unicode**: Actualmente spec asume caracteres ASCII. Si se requiere soporte Unicode, actualizar validación.

---

## 3. LISTA DE TAREAS

> Checklist accionable para Backend, Frontend y QA. El Orchestrator monitorea progreso.

### Backend

#### Implementación

- [ ] Crear modelo `User` (Pydantic schema): `UserCreate`, `UserResponse`, `UserDocument`
- [ ] Validar campos username (3-50 chars, único) y password (min 6 chars)
- [ ] Implementar `UserRepository.create(username, password)` — CRUD con inserción DB
- [ ] Implementar `UserRepository.get_by_username(username)` — lookup por username
- [ ] Implementar `UserService.register(username, password)` — lógica de negocio (verificar duplicado + crear)
- [ ] Implementar router `POST /api/v1/auth/signup` — endpoint HTTP
- [ ] Registrar router en `app.py`
- [ ] Verificar Response Time < 500ms (índice DB en `username`)
- [ ] Validar que Response 200 OK se retorna para SÍ éxito más para duplicado

#### Tests Backend (Pytest + Unittest)

- [ ] `test_user_service_register_success` — happy path, username único
- [ ] `test_user_service_register_duplicate_raises_conflict` — username ya existe
- [ ] `test_user_service_register_invalid_username_too_short` — username < 3 chars
- [ ] `test_user_service_register_invalid_password_too_short` — password < 6 chars
- [ ] `test_user_repository_create_returns_user_document` — repositorio insert
- [ ] `test_user_repository_get_by_username_returns_user` — lookup success
- [ ] `test_user_repository_get_by_username_returns_none` — lookup no encontrado
- [ ] `test_user_router_post_signup_returns_200` — endpoint éxito
- [ ] `test_user_router_post_signup_duplicate_returns_200_with_message` — duplicado
- [ ] `test_user_router_post_signup_missing_username_returns_400` — validación
- [ ] `test_user_router_post_signup_response_time_under_500ms` — performance

### Karate API Testing (Fase: QA)

> Implementado con skill `/implement-karate`. Ver [KARATE_TESTS.md](../KARATE_TESTS.md)

- [x] Feature file `users/auth/signup.feature` — scenarios Gherkin
- [x] Scenario: "CRITERIO-1.1 - Register new user successfully"
- [x] Scenario: "CRITERIO-1.2 - Reject duplicate username"
- [x] Scenario: "CRITERIO-1.3 - Validate response schema"
- [x] Scenario: "CRITERIO-1.4 - Validate response time < 500ms"
- [x] Validaciones adicionales por campos faltantes y longitud
- [x] Runner `SignupRunner.java` con configuración Karate @ `src/test/java/karate-config.js`
- [x] Logging configurado @ `src/test/java/logback-test.xml`
- [x] pom.xml actualizado con dependencias Karate JUnit5
- [ ] Ejecutar e integrar en CI/CD

### Frontend Widget / UI

**Nota**: Responsabilidad de feature separada. Aquí solo mencionado para contexto.

- [ ] (Future HU) Componente SignupForm — consume `POST /signup`
- [ ] (Future HU) Validación local (antes de enviar a backend)
- [ ] (Future HU) Manejo de errores y retry

### QA

- [ ] Ejecutar `/generate-spec` → generar esta spec ✅
- [ ] Ejecutar `/gherkin-case-generator` → criterios CRITERIO-1.1, 1.2, 1.3, 1.4 + datos de prueba
- [ ] Ejecutar `/risk-identifier` → clasificación ASD de riesgos (Duplicados=Alto, Performance=Medio)
- [ ] Ejecutar `/implement-karate` → tests de API en Karate DSL
- [ ] Revisar cobertura de tests contra criterios de aceptación
- [ ] Validar que todas las reglas de negocio están cubiertas (username único, performance, etc.)
- [ ] Ejecutar `/performance-analyzer` → definir SLAs y configurar k6 si aplica
- [ ] Actualizar estado spec: `status: APPROVED` (una vez validada con stakeholders)

---

## Aprobación

Una vez generada y revisada esta spec, debe ser **aprobada explícitamente**:

```yaml
status: APPROVED  # ← cambiar de DRAFT a APPROVED
```

Una vez en `APPROVED`, proceder con:
1. **Backend Developer** (skill `/implement-backend`)
2. **Test Engineer Backend** (skill `/unit-testing`)
3. **QA Agent** (skills `/gherkin-case-generator`, `/implement-karate`, `/risk-identifier`)

---

*Spec generada automáticamente usando skill `/generate-spec` — v1.0*

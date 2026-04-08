Historia de Usuario 2: Autenticación de Usuarios (Login)
Como Arquitecto de Seguridad
Quiero validar el endpoint de autenticación (/login)
Para asegurar que solo los usuarios legítimos puedan acceder y que los intentos fraudulentos sean bloqueados.

Criterios de Aceptación:

[ ] CA1 (Happy Path - Login Exitoso): Al proveer credenciales válidas y existentes, el sistema debe responder con un Status Code 200 OK y retornar el token de autorización o confirmación en el body.

[ ] CA2 (Credenciales Inválidas - Password): Al proveer un usuario válido pero un password incorrecto, el sistema debe responder con el mensaje de error: "Wrong password.".

[ ] CA3 (Credenciales Inválidas - Usuario): Al proveer un usuario que no existe, el sistema debe responder con el mensaje de error: "User does not exist.".

[ ] CA4 (Dependencia de Datos): El escenario de Login Exitoso debe ser capaz de consumir las credenciales creadas en la prueba de Signup de manera dinámica, demostrando un flujo End-to-End (E2E) si se ejecutan en suite.
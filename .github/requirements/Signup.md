Como Arquitecto de Seguridad
Quiero validar el endpoint de registro (/signup)
Para garantizar que los nuevos usuarios puedan darse de alta correctamente y que el sistema rechace duplicados.

Criterios de Aceptación:

[ ] CA1 (Happy Path - Registro Dinámico): Al enviar un payload con un username único generado dinámicamente y un password, el sistema debe responder con un Status Code 200 OK.

[ ] CA2 (Manejo de Duplicados): Al intentar registrar un username que ya existe en la base de datos, el sistema debe responder con un mensaje exacto: "This user already exists.".

[ ] CA3 (Validación de Contrato): El response body y headers deben cumplir con el esquema esperado de la API.

[ ] CA4 (Performance Baseline): El tiempo de respuesta (Response Time) de la API de registro no debe exceder los 500ms.
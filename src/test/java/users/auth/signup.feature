Feature: Demoblaze API - Signup and Login Testing
  Pruebas de los servicios REST de registro (signup) y login de Demoblaze
  APIs: POST https://api.demoblaze.com/signup y POST https://api.demoblaze.com/login
  
  Background:
    * def baseUrl = 'https://api.demoblaze.com'
    * def signupPath = '/signup'
    * def loginPath = '/login'
    * def getRandomEmail = function() { var ts = java.lang.System.currentTimeMillis(); var rnd = Math.floor(Math.random() * 10000); return 'testuser' + ts + rnd + '@test.com'; }
    * def testPassword = 'TestPass123'

  @signup @new-user @critical
  Scenario: CASO 1 - Crear un nuevo usuario exitosamente
    * def newEmail = getRandomEmail()
    * def signupPayload = { username: newEmail, password: testPassword }
    * karate.log('Creating new user with email: ' + newEmail)
    
    Given url baseUrl + signupPath
    And request signupPayload
    When method POST
    Then status 200
    * def responseStatus1 = response.responseCode
    * def responseMessage1 = response.message
    * karate.set('createdEmail', newEmail)
    * karate.set('createdPassword', testPassword)
    
    * print '\n' + '═══════════════════════════════════════'
    * print 'CASO 1: Crear nuevo usuario'
    * print '═══════════════════════════════════════'
    * print 'Email: ' + newEmail
    * print 'Password: ' + testPassword
    * print 'Response Code: ' + responseStatus1
    * print 'Message: ' + responseMessage1
    * print '═══════════════════════════════════════\n'

  @signup @duplicate-user @critical
  Scenario: CASO 2 - Intentar crear usuario duplicado
    * def duplicateEmail = getRandomEmail()
    * def firstPayload = { username: duplicateEmail, password: testPassword }
    * karate.log('Creating first user with email: ' + duplicateEmail)
    
    Given url baseUrl + signupPath
    And request firstPayload
    When method POST
    Then status 200
    * def firstResponse = response
    
    Given url baseUrl + signupPath
    * def duplicatePayload = { username: duplicateEmail, password: testPassword }
    And request duplicatePayload
    When method POST
    Then status 200
    * def duplicateResponse = response
    
    * print '\n' + '═══════════════════════════════════════'
    * print 'CASO 2: Usuario duplicado'
    * print '═══════════════════════════════════════'
    * print 'Email intentado (duplicado): ' + duplicateEmail
    * print 'Primer intento - Response Code: ' + firstResponse.responseCode
    * print 'Primer intento - Message: ' + firstResponse.message
    * print 'Segundo intento - Response Code: ' + duplicateResponse.responseCode
    * print 'Segundo intento - Message: ' + duplicateResponse.message
    * print '═══════════════════════════════════════\n'

  @login @valid-credentials @critical
  Scenario: CASO 3 - Login con credenciales válidas
    * def validEmail = getRandomEmail()
    * def validPassword = 'ValidPass123'
    * def createPayload = { username: validEmail, password: validPassword }
    * karate.log('Creating user for login test: ' + validEmail)
    
    Given url baseUrl + signupPath
    And request createPayload
    When method POST
    Then status 200
    
    Given url baseUrl + loginPath
    * def loginPayload = { username: validEmail, password: validPassword }
    And request loginPayload
    When method POST
    Then status 200
    * def loginResponseValid = response
    
    * print '\n' + '═══════════════════════════════════════'
    * print 'CASO 3: Login con credenciales correctas'
    * print '═══════════════════════════════════════'
    * print 'Email: ' + validEmail
    * print 'Password: ' + validPassword
    * print 'Response Code: ' + loginResponseValid.responseCode
    * print 'Message: ' + loginResponseValid.message
    * def userId3 = loginResponseValid.userId || 'N/A'
    * def token3 = loginResponseValid.token || 'N/A'
    * print 'User ID: ' + userId3
    * print 'Token: ' + token3
    * print '═══════════════════════════════════════\n'

  @login @invalid-credentials @critical
  Scenario: CASO 4 - Login con credenciales inválidas
    * def invalidEmail = 'nonexistent' + java.lang.System.currentTimeMillis() + '@test.com'
    * def invalidPassword = 'WrongPassword123'
    * karate.log('Testing login with invalid credentials: ' + invalidEmail)
    
    Given url baseUrl + loginPath
    * def invalidLoginPayload = { username: invalidEmail, password: invalidPassword }
    And request invalidLoginPayload
    When method POST
    # Note: Demoblaze may return 200 with error message, or 401/403
    Then status 200 || status 401 || status 400
    * def loginResponseInvalid = response
    
    * print '\n' + '═══════════════════════════════════════'
    * print 'CASO 4: Login con credenciales incorrectas'
    * print '═══════════════════════════════════════'
    * print 'Email (no existente): ' + invalidEmail
    * print 'Password (incorrecto): ' + invalidPassword
    * print 'HTTP Status: ' + responseStatus
    * print 'Response Code: ' + loginResponseInvalid.responseCode
    * print 'Message: ' + loginResponseInvalid.message
    * print '═══════════════════════════════════════\n'


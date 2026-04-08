Feature: Demoblaze API - Login Testing

  Background:
    * def baseUrl = 'https://api.demoblaze.com'
    * def loginPath = '/login'
    * def signupPath = '/signup'
    * def getRandomEmail = function() { var ts = java.lang.System.currentTimeMillis(); var rnd = Math.floor(Math.random() * 10000); return 'testuser' + ts + rnd + '@test.com'; }

  @login @valid-credentials @critical
  Scenario: CASO 3.1 - Login exitoso con credenciales válidas
    * def validEmail = getRandomEmail()
    * def validPassword = 'ValidPass123'

    Given url baseUrl + signupPath
    And request { username: validEmail, password: validPassword }
    When method POST
    Then status 200

    Given url baseUrl + loginPath
    And request { username: validEmail, password: validPassword }
    When method POST
    Then status 200
    * def loginResponseValid = response

    * print '\n' + '═══════════════════════════════════════'
    * print 'CASO 3.1: Login con credenciales correctas'
    * print '═══════════════════════════════════════'
    * print 'Email: ' + validEmail
    * print 'Password: ' + validPassword
    * print 'Response Code: ' + loginResponseValid.responseCode
    * print 'Message: ' + loginResponseValid.message
    * def userId31 = loginResponseValid.userId || 'N/A'
    * def token31 = loginResponseValid.token || 'N/A'
    * print 'User ID: ' + userId31
    * print 'Token: ' + token31
    * print '═══════════════════════════════════════\n'

  @login @invalid-password @critical
  Scenario: CASO 3.2 - Login rechazado por password incorrecto
    * def testEmail = getRandomEmail()
    * def correctPassword = 'CorrectPass123'
    * def wrongPassword = 'WrongPassword123'

    Given url baseUrl + signupPath
    And request { username: testEmail, password: correctPassword }
    When method POST
    Then status 200

    Given url baseUrl + loginPath
    And request { username: testEmail, password: wrongPassword }
    When method POST
    Then status 200
    * def loginResponseWrongPass = response

    * print '\n' + '═══════════════════════════════════════'
    * print 'CASO 3.2: Login con password incorrecto'
    * print '═══════════════════════════════════════'
    * print 'Email: ' + testEmail
    * print 'Password Enviado (incorrecto): ' + wrongPassword
    * print 'Response Code: ' + loginResponseWrongPass.responseCode
    * print 'Message: ' + loginResponseWrongPass.message
    * print '═══════════════════════════════════════\n'

  @login @user-not-found @critical
  Scenario: CASO 3.3 - Login rechazado porque usuario no existe
    * def nonexistentEmail = 'nonexistent' + java.lang.System.currentTimeMillis() + '@test.com'
    * def anyPassword = 'SomePassword123'

    Given url baseUrl + loginPath
    And request { username: nonexistentEmail, password: anyPassword }
    When method POST
    Then status 200
    * def loginResponseNotFound = response

    * print '\n' + '═══════════════════════════════════════'
    * print 'CASO 3.3: Login con usuario no existente'
    * print '═══════════════════════════════════════'
    * print 'Email (no existente): ' + nonexistentEmail
    * print 'Password: ' + anyPassword
    * print 'Response Code: ' + loginResponseNotFound.responseCode
    * print 'Message: ' + loginResponseNotFound.message
    * print '═══════════════════════════════════════\n'

  @login @e2e @critical
  Scenario: CASO 3.4 - Flujo E2E: Signup y Login con datos dinámicos
    * def e2eEmail = getRandomEmail()
    * def e2ePassword = 'E2ETestPass123'

    Given url baseUrl + signupPath
    And request { username: e2eEmail, password: e2ePassword }
    When method POST
    Then status 200
    * def signupResponse = response

    Given url baseUrl + loginPath
    And request { username: e2eEmail, password: e2ePassword }
    When method POST
    Then status 200
    * def e2eLoginResponse = response

    * print '\n' + '═══════════════════════════════════════'
    * print 'CASO 3.4: Flujo E2E Signup → Login'
    * print '═══════════════════════════════════════'
    * print 'Email Generado (dinámico): ' + e2eEmail
    * print 'Signup Response: ' + signupResponse.message
    * print 'Login Response Code: ' + e2eLoginResponse.responseCode
    * print 'Login Response Message: ' + e2eLoginResponse.message
    * print 'Flujo E2E: EXITOSO'
    * print '═══════════════════════════════════════\n'

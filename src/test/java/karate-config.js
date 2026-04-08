function fn() {
  var env = karate.env;
  karate.log('karate.env system property was:', env);

  if (!env) {
    env = 'dev';
  }

  var timestamp = java.lang.System.currentTimeMillis();
  var uuid = java.util.UUID.randomUUID().toString();

  var config = {
    env: env,
    baseUrl: 'https://api.demoblaze.com',
    apiUrl: 'https://api.demoblaze.com',
    contentType: 'application/json',
    timestamp: timestamp,
    uuid: uuid,
    domain: 'demoblaze.com',
    readTimeout: 5000,
    connectTimeout: 5000,
    // Shared state between feature files
    sharedTestEmail: null,
    sharedTestPassword: null
  };

  // System properties have highest priority
  if (karate.properties['baseUrl']) config.baseUrl = karate.properties['baseUrl'];
  if (karate.properties['readTimeout']) config.readTimeout = karate.properties['readTimeout'];
  if (karate.properties['connectTimeout']) config.connectTimeout = karate.properties['connectTimeout'];

  // Configure Karate with timeouts from config
  karate.configure('readTimeout', config.readTimeout);
  karate.configure('connectTimeout', config.connectTimeout);

  // Helper functions for data generation
  config.randomEmail = function() {
    var uuid = java.util.UUID.randomUUID().toString();
    return 'test-' + uuid + '@automationexercise.com';
  };

  config.testUserData = function(email) {
    var randomNum = Math.floor(Math.random() * 10000);
    return {
      name: 'Test User ' + randomNum,
      email: email || config.randomEmail(),
      password: 'password123',
      title: 'Mr.',
      firstname: 'John',
      lastname: 'Doe',
      company: 'Test Company',
      address1: '123 Test St',
      address2: 'Apt 4B',
      country: 'United States',
      state: 'NY',
      city: 'New York',
      zipcode: '10001',
      mobile_number: '+1234567890'
    };
  };

  return config;
}

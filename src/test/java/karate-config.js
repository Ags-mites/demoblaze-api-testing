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
    sharedTestEmail: null,
    sharedTestPassword: null
  };

  if (karate.properties['baseUrl']) config.baseUrl = karate.properties['baseUrl'];
  if (karate.properties['readTimeout']) config.readTimeout = karate.properties['readTimeout'];
  if (karate.properties['connectTimeout']) config.connectTimeout = karate.properties['connectTimeout'];

  karate.configure('readTimeout', config.readTimeout);
  karate.configure('connectTimeout', config.connectTimeout);

  config.getRandomEmail = function() {
    var ts = java.lang.System.currentTimeMillis();
    var rnd = Math.floor(Math.random() * 10000);
    return 'testuser' + ts + rnd + '@test.com';
  };

  config.randomEmail = function() {
    return config.getRandomEmail();
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

function fn() {
  var env = karate.env; // get java system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev'; // a custom 'intelligent' default
  }
  // base config JSON
  var config = {
    baseUrl: 'http://localhost:8004/api/v1',
    baseUrlLimitMgmt: 'http://localhost:8006/limit/api/v1',
    healthUrl: karate.properties['karate.healthUrl']

  };
  if (env == 'uat') {
    // over-ride only those that need to be
    config.someUrlBase = 'https://uat.solace-platform.rabobank.com/api/v1';
  } else if (env == 'dev') {
    config.baseUrldev = 'https://dev.solace-platform.rabobank.com/api/v1';

  }
  // don't waste time waiting for a connection or if servers don't respond within 5 seconds
  //The connection timeout is the timeout in making the initial connection; i.e. completing the TCP connection handshake.
  //The read timeout is the timeout on waiting to read data
  karate.configure('connectTimeout', 5000);
  karate.configure('readTimeout', 10000);
  karate.configure('ssl', true);
  return config;
}
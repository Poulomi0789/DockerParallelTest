function fn() {
    var env = karate.properties['env'] || 'dev';
    var config = karate.read('classpath:env/' + env + '.json');

    // Return baseUrl in config (do NOT use karate.configure for baseUrl)
    config.baseUrl = config.baseUrl;

    // Allure reporting
    karate.configure('report', { showLog: true, showAllSteps: true });

    karate.configure('connectTimeout', 5000);
    karate.configure('readTimeout', 5000);

    return config;
}

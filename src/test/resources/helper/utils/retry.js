function fn(callFn, maxRetries) {
    var attempts = 0;
    maxRetries = maxRetries || 2;
    var response;

    while (attempts <= maxRetries) {
        try {
            response = callFn();
            if (response && response.status < 500) {
                return response;
            }
        } catch (e) {
            karate.log('[RETRY] Attempt', attempts + 1, 'failed:', e);
        }
        attempts++;
    }
    throw '[RETRY] API failed after ' + maxRetries + ' attempts';
}

package runners;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import io.qameta.allure.karate.AllureKarate;

public class TestRunnerParallel {

    @Test
    void testParallel() {
        // List all feature files you want to run in parallel
        Results results = Runner.path("classpath:features")
                .hook(new AllureKarate())
                .outputCucumberJson(true)
                .parallel(4); // 🔥 Runs ALL features in parallel

        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}

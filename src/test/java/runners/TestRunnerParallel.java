package runners;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import io.qameta.allure.karate.AllureKarate;

public class TestRunnerParallel {

    @Test
    void testParallel() {

        String tags = System.getProperty("cucumber.filter.tags");

        Results results = Runner.path("classpath:features")
                .tags(tags)
                .hook(new AllureKarate())
                .outputCucumberJson(true)
                .parallel(4);

        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}

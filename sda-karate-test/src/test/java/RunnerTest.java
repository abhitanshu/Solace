import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import org.apache.commons.io.FileUtils;
import org.junit.Test;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.function.Consumer;

import static org.junit.Assert.assertTrue;

public class RunnerTest {
    @Test
    public void testParallel() {
        /*Results results = Runner.path("classpath:features").tags("@done").parallel(10);*/
        Results results = Runner.builder().outputCucumberJson(true)
                .path("classpath:features").tags("~@Ignore").parallel(1);
        generateReport(results.getReportDir());
        assertTrue(results.getErrorMessages(), results.getFailCount() == 0);
    }
    public static void generateReport(String karateOutputPath) {
        Collection jsonFiles = FileUtils.listFiles(new File(karateOutputPath), new String[] {"json"}, true);
        final List<String> jsonPaths=new ArrayList<String>(jsonFiles.size());
        jsonFiles.forEach(new Consumer<File>() {
            public void accept(File file) {
                jsonPaths.add(file.getAbsolutePath());
            }
        });
        Configuration config = new Configuration(new File("target"), "Solace Data Aggregator");
        ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
        reportBuilder.generateReports();
    }
}

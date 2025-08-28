package util;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.Random;
import java.util.UUID;

public class KarateTestUtil {

    private static final Random random = new Random();
    private static final String alphabet = "abcdefghijklmnopqrstuvwxyz";

    private KarateTestUtil() {
    }

    public static String getRandomString(int length) {
        StringBuilder result = new StringBuilder();
        Random random = new Random();
        for (int i = 0; i < length; i++) {
            result.append(alphabet.charAt(random.nextInt(alphabet.length())));
        }
        return result.toString();
    }

    public static String getDateAfterDaysfromCurrentDate(int daysToAdd) {
        LocalDate currentDate = LocalDate.now();
        LocalDate newDate = currentDate.plusDays(daysToAdd);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        return newDate.format(formatter);
    }



}

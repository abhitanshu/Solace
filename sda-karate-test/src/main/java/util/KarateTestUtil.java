package util;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.Random;
import java.util.UUID;

public class KarateTestUtil {

    private static final Random random = new Random();
    private static final String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    private static final String number = "0123456789";

    private KarateTestUtil() {
    }

    public static int getRandomObligerNumber() {
        return random.nextInt(Integer.MAX_VALUE);
    }

    public static String getRandomContractCode(int length) {
        StringBuilder result = new StringBuilder();
        Random random = new Random();

        result.append("NLUXL01");
        // Add remaining alphanumeric characters
        for (int i = 7; i < length; i++) {

            //result.append(ALPHABET.charAt(random.nextInt(ALPHABET.length())));
            result.append(number.charAt(random.nextInt(number.length())));
        }
        return result.toString();
    }

    public static String getRandomString(int length) {
        StringBuilder result = new StringBuilder();
        Random random = new Random();
        // Add two random alphabets
        result.append(alphabet.charAt(random.nextInt(26)));
        result.append(alphabet.charAt(random.nextInt(26)));
        // Add remaining alphanumeric characters
        for (int i = 2; i < length; i++) {
            result.append(alphabet.charAt(random.nextInt(alphabet.length())));
        }
        return result.toString();
    }

    public static long calculateDateDifference(String date1, String date2) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        // Parse the input date
        //For Annex Amendment createAnnex.createdAt is used which is DateTimeStamp. Extracting Date part from that.
        String date1FromTimestamp = date1.substring(0,10);
        String date2FromTimestamp = date2.substring(0,10);
        LocalDate startDate = LocalDate.parse(date1FromTimestamp, formatter);
        LocalDate endDate = LocalDate.parse(date2FromTimestamp, formatter);

        // Calculate the difference in days
        return ChronoUnit.DAYS.between(startDate, endDate);
    }

    public static String getCurrentDate() {
        LocalDate currentDate = LocalDate.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        return currentDate.format(formatter);
    }
    public static String getDateAfterSubtractingMonths(int months) {
        LocalDate today = LocalDate.now();
        LocalDate resultDate = today.minus(months, ChronoUnit.MONTHS);
        return resultDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    }
    public static String generateUUId() {
        UUID ucpId = UUID.randomUUID();
        return (ucpId.toString());
    }
}

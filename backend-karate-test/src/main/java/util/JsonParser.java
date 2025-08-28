package util;

import java.util.List;
import java.util.Map;

public class JsonParser {

    public static String getIdByCode(List<Map<String, Object>> elements, String code) {
        for (Map<String, Object> element : elements) {
            if (code.equals(element.get("code"))) {
                return (String) element.get("id");
            }
        }

        throw new CodeNotFoundException(code);
    }

    public static class CodeNotFoundException extends RuntimeException {
        public CodeNotFoundException(String code) {
            super("No id found for code: " + code);
        }
    }
}

package com.akamai.siem.connector.converter.util;

import com.akamai.siem.connector.converter.constants.TemplatesConstants;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.lang3.StringUtils;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public abstract class TemplatesUtil {
    private static final ObjectMapper mapper = new ObjectMapper();

    private static Map<String, Object> templates = null;

    public static Map<String, Object> get() throws IOException {
        if(templates == null)
            load();

        return templates;
    }

    public static void load(InputStream in) throws IOException{
        if (in == null)
            throw new IOException("Templates file not found!");

        templates = mapper.readValue(in, new TypeReference<>() {});
    }

    public static void load(String templatesFilepath) throws IOException{
        File templatesFile = new File(templatesFilepath);

        if (!templatesFile.exists() || !templatesFile.canRead()) {
            InputStream in = TemplatesUtil.class.getClassLoader().getResourceAsStream(templatesFilepath);

            if(in == null)
                in = TemplatesUtil.class.getClassLoader().getResourceAsStream(TemplatesConstants.DEFAULT_FILEPATH);

            load(in);
        }
        else
            templates = mapper.readValue(new File(templatesFilepath), new TypeReference<>(){});
    }

    public static void load() throws IOException{
        Map<String, String> environmentMap = System.getenv();
        Pattern pattern = Pattern.compile("\\$\\{(.*?)?}");
        String templatesFilepath = TemplatesConstants.FILEPATH;
        Matcher matcher = pattern.matcher(templatesFilepath);

        while(matcher.find()){
            String environmentVariableExpression = matcher.group(0);
            String environmentVariableName = matcher.group(1);
            String environmentVariableValue = environmentMap.get(environmentVariableName);

            if(environmentVariableValue == null)
                environmentVariableValue = StringUtils.EMPTY;

            templatesFilepath = StringUtils.replace(templatesFilepath, environmentVariableExpression, environmentVariableValue);
        }

        load(templatesFilepath);
    }

    public static String getMessage(String templateId) throws IOException{
        String attributeName = templateId + "." + TemplatesConstants.MESSAGE_ATTRIBUTE_ID;
        Map<String, Object> document = get();

        return JsonUtil.getAttribute(document, attributeName);
    }

    public static List<String> getBase64Fields(String templateId) throws IOException{
        String attributeName = templateId + "." + TemplatesConstants.BASE64_FIELDS_ATTRIBUTE_ID;
        Map<String, Object> document = get();

        return JsonUtil.getAttribute(document, attributeName);
    }

    public static List<String> getUrlEncodedFields(String templateId) throws IOException{
        String attributeName = templateId + "." + TemplatesConstants.URL_ENCODED_FIELDS_ATTRIBUTE_ID;
        Map<String, Object> document = get();

        return JsonUtil.getAttribute(document, attributeName);
    }

    public static List<Map<String, String>> getFieldsToBeAdded(String templateId) throws IOException{
        String attributeName = templateId + "." + TemplatesConstants.FIELDS_TO_BE_ADDED;
        Map<String, Object> document = get();

        return JsonUtil.getAttribute(document, attributeName);
    }
}
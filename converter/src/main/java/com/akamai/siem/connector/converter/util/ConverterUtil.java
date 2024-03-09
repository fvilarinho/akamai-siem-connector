package com.akamai.siem.connector.converter.util;

import com.akamai.siem.connector.converter.constants.ConverterConstants;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.lang3.StringUtils;

import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public abstract class ConverterUtil {
    private static final ObjectMapper mapper = new ObjectMapper();

    public static String decodeUrl(String encodedUrl){
        if(encodedUrl != null)
            return URLDecoder.decode(encodedUrl, StandardCharsets.UTF_8);

        return null;
    }

    public static String decodeBase64(String encodedValue){
        if (encodedValue != null) {
            String[] encodedValueParts = encodedValue.split(ConverterConstants.DEFAULT_DELIMITER);

            for (int i = 0 ; i < encodedValueParts.length ; i++)
                encodedValueParts[i] = new String(Base64.getDecoder().decode(encodedValueParts[i]), StandardCharsets.UTF_8);

            return String.join(ConverterConstants.DEFAULT_DELIMITER, encodedValueParts);
        }

        return null;
    }

    private static String name(Map<String, Object> document){
        String name = ConverterConstants.ACTIVITY_DETECTED;

        if(document != null) {
            String eventClassId = eventClassId(document);

            if (eventClassId.equalsIgnoreCase(ConverterConstants.MITIGATE_ID))
                name = ConverterConstants.ACTIVITY_MITIGATED;
        }

        return name;
    }

    private static String severity(Map<String, Object> document){
        String severity = "5";

        if(document != null) {
            String eventClassId = eventClassId(document);

            if (eventClassId.equalsIgnoreCase(ConverterConstants.MITIGATE_ID))
                severity = "10";
        }

        return severity;
    }

    private static String eventClassId(Map<String, Object> document){
        String eventClassId = ConverterConstants.DETECT_ID;

        if(document != null) {
            String action = appliedAction(document);

            if (!action.equalsIgnoreCase(ConverterConstants.ALERT_ID) && !action.equalsIgnoreCase(ConverterConstants.MONITOR_ID))
                eventClassId = ConverterConstants.MITIGATE_ID;
        }

        return eventClassId;
    }

    private static String appliedAction(Map<String, Object> document){
        if(document != null) {
            String slowPostAction = (String)document.get(ConverterConstants.SLOW_POST_ACTION_ID);

            if (slowPostAction != null) {
                if (!slowPostAction.isEmpty()) {
                    if (slowPostAction.equalsIgnoreCase("A"))
                        return ConverterConstants.ABORT_ID;

                    return ConverterConstants.ALERT_ID;
                }
            }

            String ruleActions = (String)document.get(ConverterConstants.RULE_ACTIONS_ID);

            if (ruleActions != null && !ruleActions.isEmpty()) {
                String[] ruleActionsParts = ruleActions.split(ConverterConstants.DEFAULT_DELIMITER);

                if(ruleActionsParts.length > 0)
                    return ruleActionsParts[ruleActionsParts.length - 1];
            }
        }

        return ConverterConstants.ALERT_ID;
    }

    private static String ipv6Src(String clientIp) {
        if(clientIp != null && !clientIp.isEmpty()) {
            Pattern ipv6Pattern = Pattern.compile("(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))");
            Matcher matcher = ipv6Pattern.matcher(clientIp);

            if (matcher.find())
                return clientIp;
        }

        return StringUtils.EMPTY;
    }

    private static String requestURL(Map<String, Object> document) {
        String requestURL = StringUtils.EMPTY;

        if(document != null) {
            String tls = (String)document.get(ConverterConstants.TLS_ID);

            if (tls != null && !tls.isEmpty())
                requestURL = ConverterConstants.HTTPS_SCHEME_ID;
            else
                requestURL = ConverterConstants.HTTP_SCHEME_ID;

            String host = (String)document.get(ConverterConstants.HOST_ID);

            if (host != null && !host.isEmpty())
                requestURL += host;
            else
                requestURL = StringUtils.EMPTY;

            if (!requestURL.isEmpty()) {
                String path = (String)document.get(ConverterConstants.PATH_ID);

                if (path != null && !path.isEmpty())
                    requestURL += path;
                else
                    requestURL = StringUtils.EMPTY;
            }
        }

        return requestURL;
    }

    public static void decodeUrlEncodedFields(Map<String, Object> document, String templateId) throws IOException{
        List<String> urlEncodedFields = TemplatesUtil.getUrlEncodedFields(templateId);

        if(urlEncodedFields != null && !urlEncodedFields.isEmpty()){
            for(String urlEncodedField : urlEncodedFields){
                String encodedValue = JsonUtil.getAttribute(document, urlEncodedField);
                String decodedValue = decodeUrl(encodedValue);

                JsonUtil.setAttribute(document, urlEncodedField, decodedValue);
            }
        }
    }

    public static void decodeBase64Fields(Map<String, Object> document, String templateId) throws IOException{
        List<String> base64Fields = TemplatesUtil.getBase64Fields(templateId);

        if(base64Fields != null && !base64Fields.isEmpty()){
            for(String base64Field : base64Fields){
                String encodedValue = JsonUtil.getAttribute(document, base64Field);
                String decodedValue = decodeBase64(encodedValue);

                JsonUtil.setAttribute(document, base64Field, decodedValue);
            }
        }
    }

    public static void addFields(Map<String, Object> document, String templateId) throws IOException{
        List<Map<String, String>> fieldsToBeAdded = TemplatesUtil.getFieldsToBeAdded(templateId);

        if(fieldsToBeAdded != null && !fieldsToBeAdded.isEmpty()){
            for(Map<String, String> fieldToBeAdded : fieldsToBeAdded){
                String name = fieldToBeAdded.get("name");
                String value = fieldToBeAdded.get("value");

                JsonUtil.setAttribute(document, name, processExpressions(document, value));
            }
        }
    }

    public static String process(String jsonFormattedValue) throws IOException{
        return process(jsonFormattedValue, SettingsUtil.getStorageFormatId());
    }

    public static String process(String jsonFormattedValue, String templateId) throws IOException{
        Map<String, Object> document = mapper.readValue(jsonFormattedValue, new TypeReference<>(){});

        return process(document, templateId);
    }

    public static String process(Map<String, Object> document, String templateId) throws IOException {
        decodeUrlEncodedFields(document, templateId);
        decodeBase64Fields(document, templateId);
        addFields(document, templateId);

        String value = TemplatesUtil.getMessage(templateId);

        if (value != null && !value.isEmpty())
            value = processExpressions(document, value);
        else
            value = mapper.writeValueAsString(document);

        value = value.replaceAll("\r", "");

        return value;
    }

    @SuppressWarnings("unchecked")
    private static String processExpressions(Map<String, Object> document, String valueWithExpressions){
        if(valueWithExpressions != null && !valueWithExpressions.isEmpty()) {
            Pattern pattern = Pattern.compile("@\\{(.*?)\\((.*?)\\)}");
            Matcher matcher = pattern.matcher(valueWithExpressions);

            while (matcher.find()) {
                String expression = matcher.group(0);
                String methodName = matcher.group(1);
                String[] methodParameters = matcher.group(2).split(",");
                Object[] methodParametersValues = new Object[methodParameters.length];
                int cont = 0;

                for (String methodParameterName : methodParameters) {
                    methodParameterName = StringUtils.replace(methodParameterName, "#{", "");
                    methodParameterName = StringUtils.replace(methodParameterName, "}", "");
                    methodParametersValues[cont] = JsonUtil.getAttribute(document, methodParameterName);

                    cont++;
                }

                String attributeValue;

                try {
                    attributeValue = switch (methodName) {
                        case ConverterConstants.EVENT_CLASS_ID -> eventClassId((Map<String, Object>)methodParametersValues[0]);
                        case ConverterConstants.APPLIED_ACTION_ID -> appliedAction((Map<String, Object>)methodParametersValues[0]);
                        case ConverterConstants.NAME_ID -> name((Map<String, Object>)methodParametersValues[0]);
                        case ConverterConstants.SEVERITY_ID -> severity((Map<String, Object>)methodParametersValues[0]);
                        case ConverterConstants.IPV6_SRC_ID -> ipv6Src((String) methodParametersValues[0]);
                        case ConverterConstants.REQUEST_URL_ID -> requestURL((Map<String, Object>)methodParametersValues[0]);
                        default -> null;
                    };
                }
                catch (Throwable ignored) {
                    attributeValue = null;
                }

                if (attributeValue == null)
                    attributeValue = "null";

                valueWithExpressions = StringUtils.replace(valueWithExpressions, expression, attributeValue);
            }

            pattern = Pattern.compile("#\\{(.*?)?}");
            matcher = pattern.matcher(valueWithExpressions);

            while (matcher.find()) {
                String expression = matcher.group(0);
                String attributeName = matcher.group(1);
                Object attributeValue = JsonUtil.getAttribute(document, attributeName);

                if(attributeValue == null)
                    attributeValue = StringUtils.EMPTY;

                if(attributeValue instanceof String) {
                    do {
                        valueWithExpressions = StringUtils.replace(valueWithExpressions, expression, (String)attributeValue);
                    }
                    while (valueWithExpressions.contains(expression));
                }
            }
        }

        return valueWithExpressions;
    }
}
package com.akamai.siem.connector.converter.constants;

public class TemplatesConstants {
    public static final String DEFAULT_ETC_DIR = "etc/";
    public static final String DEFAULT_FILENAME = "templates.json";
    public static final String DEFAULT_FILEPATH = DEFAULT_ETC_DIR.concat(DEFAULT_FILENAME);
    public static final String FILEPATH = "${ETC_DIR}/".concat(DEFAULT_FILENAME);
    public static final String MESSAGE_ATTRIBUTE_ID = "message";
    public static final String BASE64_FIELDS_ATTRIBUTE_ID = "base64Fields";
    public static final String URL_ENCODED_FIELDS_ATTRIBUTE_ID = "urlEncodedFields";
    public static final String FIELDS_TO_BE_ADDED = "fieldsToBeAdded";
}
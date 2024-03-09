package com.akamai.siem.connector.converter.constants;

public class SettingsConstants {
    public static final String DEFAULT_ETC_DIR = "etc/";
    public static final String DEFAULT_FILENAME = "settings.json";
    public static final String DEFAULT_FILEPATH = DEFAULT_ETC_DIR.concat(DEFAULT_FILENAME).concat(".original");
    public static final String DEFAULT_KAFKA_INBOUND_TOPIC = "eventsCollected";
    public static final String DEFAULT_KAFKA_OUTBOUND_TOPIC = "eventsProcessed";
    public static final String DEFAULT_KAFKA_BROKERS = "kafka-broker:9092";
    public static final String DEFAULT_STORAGE_FORMAT_ID = "json";
    public static final Integer DEFAULT_WORKERS = 10;
    public static final String FILEPATH = "${ETC_DIR}/".concat(DEFAULT_FILENAME);
    public static final String KAFKA_BROKERS_ATTRIBUTE_ID = "kafka.brokers";
    public static final String KAFKA_INBOUND_TOPIC_ATTRIBUTE_ID = "kafka.inboundTopic";
    public static final String KAFKA_OUTBOUND_TOPIC_ATTRIBUTE_ID = "kafka.outboundTopic";
    public static final String WORKERS_ATTRIBUTE_ID = "workers";
    public static final String STORAGE_FORMAT_ID = "storageFormatId";
}
package com.akamai.siem.connector.converter.constants;

public abstract class ConverterConstants {
    public static final String EVENT_CLASS_ID = "eventClassId";
    public static final String APPLIED_ACTION_ID = "appliedAction";
    public static final String NAME_ID = "name";
    public static final String SEVERITY_ID = "severity";
    public static final String IPV6_SRC_ID = "ipv6Src";
    public static final String REQUEST_URL_ID = "requestURL";
    public static final String ALERT_ID = "alert";
    public static final String MONITOR_ID = "monitor";
    public static final String DETECT_ID = "detect";
    public static final String MITIGATE_ID = "mitigate";
    public static final String ABORT_ID = "abort";
    public static final String ACTIVITY_DETECTED = "Activity detected";
    public static final String ACTIVITY_MITIGATED = "Activity mitigated";
    public static final String SLOW_POST_ACTION_ID = "slowPostAction";
    public static final String RULE_ACTIONS_ID = "ruleActions";
    public static final String HOST_ID = "host";
    public static final String TLS_ID = "tls";
    public static final String PATH_ID = "path";
    public static final String HTTPS_SCHEME_ID = "https://";
    public static final String HTTP_SCHEME_ID = "http://";
    public static final Integer DEFAULT_WORKERS_TIMEOUT = 60;
    public static final String DEFAULT_DELIMITER = ";";
}
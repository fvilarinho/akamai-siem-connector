package com.akamai.siem.connector.converter.util;

import java.util.HashMap;
import java.util.Map;

public abstract class JsonUtil {
    @SuppressWarnings("unchecked")
    public static <O> O getAttribute(Map<String, Object> document, String attributeName) {
        String[] parts = attributeName.split("\\.");
        Map<String, Object> parentNode = document;

        for(int i = 0 ; i < (parts.length - 1); i++) {
            Object partObject = parentNode.get(parts[i]);

            if(partObject == null)
                break;

            if(partObject instanceof Map)
                parentNode = (Map<String, Object>)partObject;
            else{
                parentNode = null;

                break;
            }
        }

        if(parentNode != null)
            return (O)parentNode.get(parts[parts.length - 1]);

        return null;
    }

    @SuppressWarnings("unchecked")
    public static void setAttribute(Map<String, Object> document, String attributeName, Object value){
        String[] parts = attributeName.split("\\.");
        Map<String, Object> parentNode = document;

        for(int i = 0 ; i < (parts.length - 1); i++) {
            Object partObject = parentNode.computeIfAbsent(parts[i], p -> new HashMap<>());

            if(partObject instanceof Map)
                parentNode = (Map<String, Object>)partObject;
            else {
                parentNode = null;

                break;
            }
        }

        if(parentNode != null)
            parentNode.put(parts[parts.length - 1], value);
    }
}
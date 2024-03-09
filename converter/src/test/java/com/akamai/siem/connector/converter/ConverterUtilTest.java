package com.akamai.siem.connector.converter;

import com.akamai.siem.connector.converter.constants.TestConstants;
import com.akamai.siem.connector.converter.util.ConverterUtil;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Objects;

public class ConverterUtilTest {
    private static String originMessageNode;
    private static String expectedCefMessage;
    private static String expectedDecodedMessage;

    @BeforeAll
    static void loadMessages(){
        try {
            originMessageNode = Files.readString(Paths.get(Objects.requireNonNull(ConverterUtilTest.class.getClassLoader().getResource(TestConstants.DEFAULT_ORIGINAL_MESSAGE_FILENAME)).toURI()));
            expectedCefMessage = Files.readString(Paths.get(Objects.requireNonNull(ConverterUtilTest.class.getClassLoader().getResource(TestConstants.DEFAULT_EXPECTED_CEF_MESSAGE_FILENAME)).toURI()));
            expectedDecodedMessage = Files.readString(Paths.get(Objects.requireNonNull(ConverterUtilTest.class.getClassLoader().getResource(TestConstants.DEFAULT_EXPECTED_DECODED_MESSAGE_FILENAME)).toURI()));
        }
         catch(IOException | URISyntaxException e){
            Assertions.fail(e);
        }
    }

    @Test
    void fromJsonToCef_test() {
        try {
            Assertions.assertEquals(expectedCefMessage, ConverterUtil.process(originMessageNode, "cef"));
        }
        catch(Throwable e){
            Assertions.fail(e);
        }
    }

    @Test
    void decodeJsonAndEnrich_test() {
        try {
            Assertions.assertEquals(expectedDecodedMessage, ConverterUtil.process(originMessageNode, "json"));
        }
        catch(IOException e){
            Assertions.fail(e);
        }
    }
}
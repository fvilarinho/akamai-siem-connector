package com.akamai.siem.connector.converter;

import com.akamai.siem.connector.converter.constants.Constants;
import com.akamai.siem.connector.converter.constants.ConverterConstants;
import com.akamai.siem.connector.converter.util.SettingsUtil;
import com.akamai.siem.connector.converter.util.helpers.ConverterWorker;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.time.Duration;
import java.util.Collections;
import java.util.Properties;
import java.util.Scanner;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class App implements Runnable {
    private static final Logger logger = LogManager.getLogger(Constants.DEFAULT_APP_NAME);

    public static String getId() throws IOException {
        try (Scanner s = new Scanner(Runtime.getRuntime().exec("hostname").getInputStream()).useDelimiter("\\A")) {
            return s.hasNext() ? s.next() : "";
        }
    }

    private static Properties prepareKafkaConsumerParameters() throws IOException{
        String brokers = SettingsUtil.getKafkaBrokers();

        logger.info("Preparing the inbound connection to " + brokers + "...");

        Properties properties = new Properties();

        properties.setProperty(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, SettingsUtil.getKafkaBrokers());
        properties.setProperty(ConsumerConfig.GROUP_ID_CONFIG, Constants.DEFAULT_APP_NAME);
        properties.setProperty(ConsumerConfig.CLIENT_ID_CONFIG, getId());
        properties.setProperty(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.setProperty(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.setProperty(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

        return properties;
    }

    private static Properties prepareKafkaProducerParameters() throws IOException{
        String brokers = SettingsUtil.getKafkaBrokers();

        logger.info("Preparing the outbound connection to " + brokers + "...");

        Properties properties = new Properties();

        properties.setProperty(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, SettingsUtil.getKafkaBrokers());
        properties.setProperty(ProducerConfig.CLIENT_ID_CONFIG, getId());
        properties.setProperty(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        properties.setProperty(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        return properties;
    }

    public void run(){
        KafkaProducer<String, String> producer = null;
        KafkaConsumer<String, String> consumer = null;

        try {
            logger.info("Loading settings...");

            final String inboundTopic = SettingsUtil.getKafkaInboundTopic();
            final String outboundTopic = SettingsUtil.getKafkaOutboundTopic();

            logger.info("Settings loaded!");

            producer = new KafkaProducer<>(prepareKafkaProducerParameters());
            consumer = new KafkaConsumer<>(prepareKafkaConsumerParameters());

            logger.info("Subscribing to the queue " + inboundTopic + "...");

            consumer.subscribe(Collections.singletonList(inboundTopic));

            ExecutorService workersManager = Executors.newFixedThreadPool(SettingsUtil.getWorkers());

            while (true) {
                try {
                    ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));

                    if (!records.isEmpty()) {
                        logger.info(records.count() + " messages fetched from the queue " + inboundTopic);

                        for (ConsumerRecord<String, String> record : records)
                            workersManager.submit(new ConverterWorker(producer, record, outboundTopic));

                        logger.info(records.count() + " messages stored in the queue " + outboundTopic);
                    }
                }
                catch(Throwable e) {
                    logger.error(e);

                    break;
                }
            }

            logger.info("Waiting the conversion workers stop...");

            try {
                workersManager.shutdown();

                if(workersManager.awaitTermination(ConverterConstants.DEFAULT_WORKERS_TIMEOUT, TimeUnit.SECONDS))
                    logger.info("Conversion workers terminated!");
                else
                    logger.info("Termination timeout reached!");
            }
            catch(Throwable ignored){
            }
        }
        catch(Throwable e){
            logger.error(e);
        }
        finally {
            if(producer != null)
                producer.close();

            if(consumer != null)
                consumer.close();
        }
    }

    public static void main(String[] args){
        new App().run();
    }
}
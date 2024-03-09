package com.akamai.siem.connector.converter.util.helpers;

import com.akamai.siem.connector.converter.constants.Constants;
import com.akamai.siem.connector.converter.util.ConverterUtil;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class ConverterWorker implements Runnable {
    private static final Logger logger = LogManager.getLogger(Constants.DEFAULT_APP_NAME);

    private final KafkaProducer<String, String> producer;
    private final ConsumerRecord<String, String> record;
    private final String topic;

    public ConverterWorker(KafkaProducer<String, String> producer, ConsumerRecord<String, String> record, String topic) {
        this.producer = producer;
        this.record = record;
        this.topic = topic;
    }

    @Override
    public void run() {
        try {
            String key = this.record.key();
            String value = this.record.value();

            if (value != null && !value.isEmpty()) {
                value = ConverterUtil.process(value);

                this.producer.send(new ProducerRecord<>(this.topic, key, value));
                this.producer.flush();
            }
        }
        catch (Throwable e) {
            System.out.println(this.record.value());

            logger.error(e);
        }
    }
}
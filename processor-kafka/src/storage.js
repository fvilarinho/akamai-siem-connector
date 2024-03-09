const { Kafka } = require("kafkajs");
const os = require("os");

const kafkaClientId = os.hostname();

const storeEvents = async function (eventsRaw, settingsObject){
    let producer;
    let kafkaClient;

    try {
        const now = new Date();
        const eventsObject = JSON.parse(eventsRaw.toString());

        kafkaClient = new Kafka({
            brokers: settingsObject.kafka.brokers,
            clientId: kafkaClientId
        });

        producer = kafkaClient.producer({
            maxBytesPerPartition: settingsObject.maxMessageSize
        });

        await producer.connect();
        await producer.send({
            topic: settingsObject.kafka.topic,
            messages: eventsObject.events
        });

        console.log(`[${now}][${eventsObject.events.length} events were stored in queue ${settingsObject.kafka.topic} for the job ${eventsObject.job}]`);
    }
    catch (error) {
        console.error(error);
    }
    finally {
        if (producer)
            await producer.disconnect();

        kafkaClient = null;
    }
};

module.exports = { storeEvents };
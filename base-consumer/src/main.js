const settings = require("./settings.js");
const akamai = require("./events.js");
const mqtt = require("mqtt");
const os = require("os");

const settingsObject = settings.loadSettings();
const mqttClientId = os.hostname();
const mqttClient = mqtt.connect(`mqtt://${settingsObject.scheduler}`, { clientId: mqttClientId });

mqttClient.subscribe(settingsObject.inputQueue, function (error) {
    const now = new Date();

    if (!error)
        console.log(`[${now}][${mqttClientId} subscribed the queue ${settingsObject.inputQueue}]`);
    else {
        console.log(`[${now}][An error occurred while ${mqttClientId} was trying to subscribe the queue ${settingsObject.inputQueue}]`);
        console.error(error);

        mqttClient.end(true);
    }
});

mqttClient.on("connect", function (packet) {
    const now = new Date();

    console.log(`[${now}][${mqttClientId} connected to ${settingsObject.scheduler}]`);
});

mqttClient.on("message", async function (queue, messageRaw, packet) {
    try {
        let now = new Date();
        const messageObject = JSON.parse(messageRaw.toString());

        console.log(`[${now}][${mqttClientId} received the job ${messageObject.job} from queue ${settingsObject.inputQueue}]`);

        const result = akamai.fetchEvents(messageObject, settingsObject);

        result.then((eventsObject) => {
            if (eventsObject && eventsObject.events && eventsObject.events.length > 0) {
                let lastEvent = eventsObject.events[eventsObject.events.length - 1];

                if (lastEvent && lastEvent.value) {
                    lastEvent = JSON.parse(lastEvent.value);

                    if (lastEvent.offset) {
                        const offsetJobObject = {
                            job: messageObject.job,
                            offset: lastEvent.offset,
                            maxEventsPerJob: messageObject.maxEventsPerJob
                        }

                        mqttClient.publish(settingsObject.inputQueue, JSON.stringify(offsetJobObject));
                    }
                }

                mqttClient.publish(settingsObject.outputQueue, JSON.stringify(eventsObject));

                now = new Date();

                console.log(`[${now}][${mqttClientId} published ${eventsObject.events.length} events in the queue ${settingsObject.outputQueue} for job ${messageObject.job}]`);
            }
            else
                console.log(`[${now}][${mqttClientId} did not find more events to be fetched for the job ${messageObject.job}]`);
        }).catch((error) => console.log(error));
    }
    catch(error) {
        console.log(error);
    }
});

mqttClient.on("error", function (error) {
    console.log(error);
});
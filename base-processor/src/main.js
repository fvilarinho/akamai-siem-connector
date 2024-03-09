const settings = require("./settings.js");
const storage = require("./storage.js");
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
    storage.storeEvents(messageRaw, settingsObject);
});

mqttClient.on("error", function (error) {
    console.log(error);
});
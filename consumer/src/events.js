const EdgeGrid = require('akamai-edgegrid');
const linebreak = "\\n";

const fetchEvents = async function (messageObject, settingsObject) {
    return new Promise(function (resolve, reject) {
        try{
            const authParams = {
                path: settingsObject.edgercFilename,
                section: settingsObject.edgercSectionName
            }

            const eg = new EdgeGrid(authParams);
            let url;

            if (messageObject.offset)
                url = `/siem/v1/configs/${settingsObject.configsIds}?limit=${messageObject.maxEventsPerJob}&offset=${messageObject.offset}`;
            else
                url = `/siem/v1/configs/${settingsObject.configsIds}?limit=${messageObject.maxEventsPerJob}&from=${messageObject.from}&to=${messageObject.to}`;

            const fetchEventsParams = {
                path: url,
                method: "GET",
                headers: {
                    Accept: "application/json"
                }
            };

            eg.auth(fetchEventsParams);
            eg.send(function (error, response, body) {
                try{
                    if (error) {
                        console.error(error);

                        return resolve(null);
                    }

                    let eventsList = [];
                    const eventsBuffer = body.split(linebreak);

                    eventsBuffer.forEach((item, index) => {
                        if (item.length > 0 && index < (eventsBuffer.length - 1)) {
                            let key = messageObject.job + "-" + index;
                            let value = item.replace("'", "").replace(/\\/g, "");

                            if(value.startsWith("\""))
                                value = value.substring(1);

                            let eventObject = {
                                key: key,
                                value: value
                            };

                            eventsList.push(eventObject);
                        }
                    });

                    const eventsObject = {
                        job: messageObject.job,
                        events: eventsList
                    };

                    return resolve(eventsObject);
                }
                catch (error) {
                    return reject(error);
                }
            });
        }
        catch (error) {
            return reject(error);
        }
    });
};

module.exports = { fetchEvents };
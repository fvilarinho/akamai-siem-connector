const utils = require("./utils.js");
const path = require("path");
const os = require("os");

const storeEvents = async function (eventsRaw, settingsObject) {
    try {
        const now = new Date();
        const filename = path.join(process.env.DATA_DIR, `${now.getTime()}.json`);

        utils.writeFile(filename, eventsRaw);

        console.log(`[${now}][${eventsRaw.length} bytes of events were stored in ${filename}]`);
    }
    catch (error) {
        console.error(error);
    }
};

module.exports = { storeEvents };
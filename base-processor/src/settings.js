const utils = require("./utils.js");
const settingFilename = process.env.ETC_DIR + "/settings.json";

const loadSettings = function () {
    return JSON.parse(utils.loadFile(settingFilename));
};

module.exports = { loadSettings };
const fs = require("fs");

const loadFile = function (filename) {
    return fs.readFileSync(filename);
};

const writeFile = function (filename, content) {
    fs.writeFileSync(filename, content);
};

module.exports = { loadFile, writeFile };
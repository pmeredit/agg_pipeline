const parser = require("./agg_pipeline.js");
const fs = require("fs");

var input = fs.readFileSync('test').toString().replace(/\s+/g, '');
var output = parser.parse(input)
console.log("_____");
console.log(output);
console.log("_____");
console.log(output[0]);


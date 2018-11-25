'use strict';

var AWS = require('aws-sdk');
var mysql = require('mysql');

var mysql      = require('mysql');
var connection = mysql.createConnection({
    host     : process.env.DATABASE_HOST,
    user     : process.env.DATABASE_USER,
    password : process.env.DATABASE_PASS,
    database : 'junctionDatabase'
});

exports.handler = function(event, context) {

    // prepare SQL
    let sqlStatementCount = 'SELECT temp, timestamp FROM tempdata where temp > 0 order by timestamp desc limit 7';

    connection.query(sqlStatementCount, function(err, rows) {

        if (err) {
            // connection error
            console.error('error connecting: ' + err.stack);
            
            context.fail();
            return;
        }
        
        const response = {
            statusCode: 200,
            value0temp: rows[0].temp,
            value0time: rows[0].timestamp,
            value1temp: rows[1].temp,
            value1time: rows[1].timestamp,
            value2temp: rows[2].temp,
            value2time: rows[2].timestamp,
            value3temp: rows[3].temp,
            value3time: rows[3].timestamp,
            value4temp: rows[4].temp,
            value4time: rows[4].timestamp,
            value5temp: rows[5].temp,
            value5time: rows[5].timestamp,
            value6temp: rows[6].temp,
            value6time: rows[6].timestamp
        };

        context.succeed(response);
    });

};

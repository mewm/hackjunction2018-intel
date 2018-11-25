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

    // node ID
    let nodeSendingData = event.node;
    // node temperature
    let receivedTemperature = event.temperature;
    // time stamp
    let timestamp = new Date().toISOString().slice(0, 19).replace('T', ' ');

    // prepare SQL
    let sqlStatement = 'INSERT INTO tempdata (temp, node, timestamp) VALUES (' + receivedTemperature + ',' + nodeSendingData + ',"' + timestamp + '")';
    
    // console.log(sqlStatement);

    connection.query(sqlStatement, function(err, rows) {

        if (err) {
            // connection error
            console.error('error connecting: ' + err.stack);
            
            context.fail();
            return;
        }

        context.succeed(rows);
    });

};

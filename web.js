//    MissJuliaRobot (A Telegram Bot Project)
//    Copyright (C) 2019-Present Anonymous (https://t.me/MissJulia_Robot)

//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Affero General Public License as published by
//    the Free Software Foundation, in version 3 of the License.

//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Affero General Public License for more details.

//    You should have received a copy of the GNU Affero General Public License
//    along with this program.  If not, see < https://www.gnu.org/licenses/agpl-3.0.en.html >


var express = require('express'); //importing express

var http = require('http'); //importing http

var Ddos = require('ddos'); //importing ddos

var app = express();

var newBaseURL = process.env.WEBSITE_URL || 'www.google.com';

var redirectStatus = parseInt(302);

var port = process.env.PORT;

app.get('*', function(request, response) {

  response.redirect(redirectStatus, newBaseURL + request.url);

});

app.listen(port, function() {

  console.log("\n" + "Listening on " + newBaseURL + " at port " + port + "\n");

});

// This limits a user to make only 3 requests per second
var ddos = new Ddos({burst:3, limit:1})

app.use(ddos.express);


// Function to prevent heroku dynos from idling
// This may not be needed if your application has a good traffic

// Fetching environment variables
var HEROKU_APP_NAME = process.env.HEROKU_APP_NAME;
var HEROKU_APP_URL = HEROKU_APP_NAME + '.herokuapp.com';


function startKeepAlive() {

    setInterval(function() {

        var options = {

            host: HEROKU_APP_URL,

            port: 80,

            path: '/'

        };

        http.get(options, function(res) {

            res.on('data', function(chunk) {

                try {

                    // optional logging... disable after it's working
                    console.log("HEROKU RESPONSE: " + chunk);

                } catch (err) {

                    console.log(err.message);

                }

            });

        }).on('error', function(err) {

            console.log("Error: " + err.message);

        });

    }, 10 * 60 * 1000); // load every 10 minutes

}

// ends 

startKeepAlive();

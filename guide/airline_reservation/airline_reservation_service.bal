// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/mysql;
import ballerina/sql;
//import ballerinax/docker;
//import ballerinax/kubernetes;

//@docker:Config {
//    registry:"ballerina.guides.io",
//    name:"airline_reservation_service",
//    tag:"v1.0"
//}
//
//@docker:Expose{}

//@kubernetes:Ingress {
//  hostname:"ballerina.guides.io",
//  name:"ballerina-guides-airline-reservation-service",
//  path:"/"
//}
//
//@kubernetes:Service {
//  serviceType:"NodePort",
//  name:"ballerina-guides-airline-reservation-service"
//}
//
//@kubernetes:Deployment {
//  image:"ballerina.guides.io/airline_reservation_service:v1.0",
//  name:"ballerina-guides-airline-reservation-service"
//}

// Service endpoint
endpoint http:Listener airlineEP {
    port:9091
};

// Airline reservation service
@http:ServiceConfig {basePath:"/airline"}
service<http:Service> airlineReservationService bind airlineEP {

    // Resource 'flightConcord', which checks about airline 'Qatar Airways'
    @http:ResourceConfig {methods:["POST"], path:"/qatarAirways", consumes:["application/json"],
        produces:["application/json"]}
    flightConcord (endpoint caller, http:Request request) {
        http:Response response;
        json reqPayload;

        // Try parsing the JSON payload from the request
        match request.getJsonPayload() {
            // Valid JSON payload
            json payload => reqPayload = payload;
            // NOT a valid JSON payload
            any => {
                response.statusCode = 400;
                response.setJsonPayload({"Message":"Invalid payload - Not a valid JSON payload"});
                _ = caller -> respond(response);
                done;
            }
        }

        string arrivalDate = <string> reqPayload.ArrivalDate but {error => ""};
        string departureDate = <string> reqPayload.DepartureDate but {error => ""};
        string rom = <string> reqPayload.From but {error => ""};
        string to = <string> reqPayload.To but {error => ""};
        string airline = "Qatar";

        // If payload parsing fails, send a "Bad Request" message as the response
        if (arrivalDate == null || departureDate == null || rom == null || to == null) {
            response.statusCode = 400;
            response.setJsonPayload({"Message":"Bad Request - Invalid Payload"});
            _ = caller -> respond(response);
            done;
        }

        // Response payload
        response.setJsonPayload(untaint airlineDBService(airline, departureDate, arrivalDate, to, rom));
        // Send the response to the caller
        _ = caller -> respond(response);
    }

    // Resource 'flightAsiana', which checks about airline 'Asiana'
    @http:ResourceConfig {methods:["POST"], path:"/asiana", consumes:["application/json"],
        produces:["application/json"]}
    flightAsiana (endpoint caller, http:Request request) {
        http:Response response;
        json reqPayload;

        // Try parsing the JSON payload from the request
        match request.getJsonPayload() {
            // Valid JSON payload
            json payload => reqPayload = payload;
            // NOT a valid JSON payload
            any => {
                response.statusCode = 400;
                response.setJsonPayload({"Message":"Invalid payload - Not a valid JSON payload"});
                _ = caller -> respond(response);
                done;
            }
        }

        string arrivalDate = <string> reqPayload.ArrivalDate but {error => ""};
        string departureDate = <string> reqPayload.DepartureDate but {error => ""};
        string rom = <string> reqPayload.From but {error => ""};
        string to = <string> reqPayload.To but {error => ""};
        string airline = "Asiana";

        // If payload parsing fails, send a "Bad Request" message as the response
        if (arrivalDate == null || arrivalDate == null || rom == null || to == null) {
            response.statusCode = 400;
            response.setJsonPayload({"Message":"Bad Request - Invalid Payload"});
            _ = caller -> respond(response);
            done;
        }

        // Response payload
        response.setJsonPayload(untaint airlineDBService(airline, departureDate, arrivalDate, to, rom));
        // Send the response to the caller
        _ = caller -> respond(response);
    }

    // Resource 'flightEmirates', which checks about airline 'Emirates'
    @http:ResourceConfig {methods:["POST"], path:"/emirates", consumes:["application/json"],
        produces:["application/json"]}
    flightEmirates (endpoint caller, http:Request request) {
        http:Response response;
        json reqPayload;

        // Try parsing the JSON payload from the request
        match request.getJsonPayload() {
            // Valid JSON payload
            json payload => reqPayload = payload;
            // NOT a valid JSON payload
            any => {
                response.statusCode = 400;
                response.setJsonPayload({"Message":"Invalid payload - Not a valid JSON payload"});
                _ = caller -> respond(response);
                done;
            }
        }

        string arrivalDate = <string> reqPayload.ArrivalDate but {error => ""};
        string departureDate = <string> reqPayload.DepartureDate but {error => ""};
        string rom = <string> reqPayload.From but {error => ""};
        string to = <string> reqPayload.To but {error => ""};
        string airline = "Emirates";

        // If payload parsing fails, send a "Bad Request" message as the response
        if (arrivalDate == null || departureDate == null || rom == null || to == null) {
            response.statusCode = 400;
            response.setJsonPayload({"Message":"Bad Request - Invalid Payload"});
            _ = caller -> respond(response);
            done;
        }

        // Mock logic
        // Details of the airline
    //    json flightDetails = {
    //         "Airline":"Emirates",
    //         "ArrivalDate":arrivalDate,
    //         "ReturnDate":departureDate,
    //         "From":fromPlace,
    //         "To":toPlace,
    //         "Price":273
    //     }; 
        // Response payload
        response.setJsonPayload(untaint airlineDBService(airline, departureDate, arrivalDate, to, rom));
        // Send the response to the caller
        _ = caller -> respond(response);
    }
}

type Flight record {
    int flightNo;
    string airline;
    string arrivalDate;
    string departureDate;
    string to;
    string rom;
    int price;
};

endpoint mysql:Client airLineDB{
    host:"localhost",
    port:3306,
    name:"testdb2",
    username:"root",
    password:"root",
    dbOptions: { useSSL: false }
};

function airlineDBService (string airline, string departureDate, string arrivalDate, string to, string rom) returns (json){
    sql:Parameter p1 = {sqlType:sql:TYPE_VARCHAR, value:airline};
    sql:Parameter p2 = {sqlType:sql:TYPE_DATE, value:departureDate};
    sql:Parameter p3 = {sqlType:sql:TYPE_DATE, value:arrivalDate};
    sql:Parameter p4 = {sqlType:sql:TYPE_VARCHAR, value:to};
    sql:Parameter p5 = {sqlType:sql:TYPE_VARCHAR, value:rom};
    string q = "SELECT * FROM FLIGHTS WHERE airline = ? AND departureDate = ? AND arrivalDate = ? AND dest = ? AND rom = ?";
    var temp = airLineDB -> select(q, Flight, p1, p2, p3, p4, p5);
    table<Flight> flights = check temp;
    Flight flight = {};
    foreach i in flights {
        flight.flightNo = i.flightNo;
        flight.airline = i.airline;
        flight.departureDate = i.departureDate;
        flight.arrivalDate = i.arrivalDate;
        flight.to = i.to;
        flight.rom = i.rom;
        flight.price = i.price;
    }
    return <json> flight but {error => {}};
}

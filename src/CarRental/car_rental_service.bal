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

package CarRental;

import ballerina/http;

// Service endpoint
endpoint http:ServiceEndpoint carEP {
    port:9093
};

// Car rental service
@http:ServiceConfig {basePath:"/car"}
service<http:Service> carRentalService bind carEP {

    // Resource 'driveSg', which checks about hotel 'DriveSg'
    @http:ResourceConfig {methods:["POST"], path:"/driveSg", consumes:["application/json"],
                          produces:["application/json"]}
    driveSg (endpoint client, http:Request request) {
        http:Response response = {};
        json reqPayload;

        // Try parsing the JSON payload from the request
        match request.getJsonPayload() {
        // Valid JSON payload
            json payload => reqPayload = payload;
        // NOT a valid JSON payload
            any | null => {
                response.statusCode = 400;
                response.setJsonPayload({"Message":"Invalid payload - Not a valid JSON payload"});
                _ = client -> respond(response);
                //return;
            }
        }

        json arrivalDate = reqPayload.ArrivalDate;
        json departureDate = reqPayload.DepartureDate;
        json vehicleType = reqPayload.VehicleType;

        // If payload parsing fails, send a "Bad Request" message as the response
        if (arrivalDate == null || departureDate == null || vehicleType == null) {
            response.statusCode = 400;
            response.setJsonPayload({"Message":"Bad Request - Invalid Payload"});
            _ = client -> respond(response);
            //return;
        }

        // Mock logic
        // Details of the vehicle
        json vehicleDetails = {
                                  "Company":"DriveSG",
                                  "VehicleType":vehicleType,
                                  "FromDate":arrivalDate,
                                  "ToDate":departureDate,
                                  "PricePerDay":5
                              };
        // Response payload
        response.setJsonPayload(vehicleDetails);
        // Send the response to the client
        _ = client -> respond(response);
    }

    // Resource 'dreamCar', which checks about hotel 'DreamCar'
    @http:ResourceConfig {methods:["POST"], path:"/dreamCar", consumes:["application/json"],
                          produces:["application/json"]}
    dreamCar (endpoint client, http:Request request) {
        http:Response response = {};
        json reqPayload;

        // Try parsing the JSON payload from the request
        match request.getJsonPayload() {
        // Valid JSON payload
            json payload => reqPayload = payload;
        // NOT a valid JSON payload
            any | null => {
                response.statusCode = 400;
                response.setJsonPayload({"Message":"Invalid payload - Not a valid JSON payload"});
                _ = client -> respond(response);
                //return;
            }
        }

        json arrivalDate = reqPayload.ArrivalDate;
        json departureDate = reqPayload.DepartureDate;
        json vehicleType = reqPayload.VehicleType;

        // If payload parsing fails, send a "Bad Request" message as the response
        if (arrivalDate == null || departureDate == null || vehicleType == null) {
            response.statusCode = 400;
            response.setJsonPayload({"Message":"Bad Request - Invalid Payload"});
            _ = client -> respond(response);
            //return;
        }

        // Mock logic
        // Details of the vehicle
        json vehicleDetails = {
                                  "Company":"DreamCar",
                                  "VehicleType":vehicleType,
                                  "FromDate":arrivalDate,
                                  "ToDate":departureDate,
                                  "PricePerDay":6
                              };
        // Response payload
        response.setJsonPayload(vehicleDetails);
        // Send the response to the client
        _ = client -> respond(response);
    }

    // Resource 'sixt', which checks about hotel 'Sixt'
    @http:ResourceConfig {methods:["POST"], path:"/sixt", consumes:["application/json"], produces:["application/json"]}
    sixt (endpoint client, http:Request request) {
        http:Response response = {};
        json reqPayload;

        // Try parsing the JSON payload from the request
        match request.getJsonPayload() {
        // Valid JSON payload
            json payload => reqPayload = payload;
        // NOT a valid JSON payload
            any | null => {
                response.statusCode = 400;
                response.setJsonPayload({"Message":"Invalid payload - Not a valid JSON payload"});
                _ = client -> respond(response);
                //return;
            }
        }

        json arrivalDate = reqPayload.ArrivalDate;
        json departureDate = reqPayload.DepartureDate;
        json vehicleType = reqPayload.VehicleType;

        // If payload parsing fails, send a "Bad Request" message as the response
        if (arrivalDate == null || departureDate == null || vehicleType == null) {
            response.statusCode = 400;
            response.setJsonPayload({"Message":"Bad Request - Invalid Payload"});
            _ = client -> respond(response);
            //return;
        }

        // Mock logic
        // Details of the vehicle
        json vehicleDetails = {
                                  "Company":"Sixt",
                                  "VehicleType":vehicleType,
                                  "FromDate":arrivalDate,
                                  "ToDate":departureDate,
                                  "PricePerDay":7
                              };
        // Response payload
        response.setJsonPayload(vehicleDetails);
        // Send the response to the client
        _ = client -> respond(response);
    }
}

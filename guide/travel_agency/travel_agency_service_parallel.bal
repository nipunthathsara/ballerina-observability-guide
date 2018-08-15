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
import ballerina/observe;
import ballerina/log;
//import ballerinax/docker;
//import ballerinax/kubernetes;

//@docker:Config {
//    registry:"ballerina.guides.io",
//    name:"travel_agency_service",
//    tag:"v1.0"
//}
//
//@docker:Expose{}

//@kubernetes:Ingress {
//  hostname:"ballerina.guides.io",
//  name:"ballerina-guides-travel-agency-service",
//  path:"/"
//}
//
//@kubernetes:Service {
//  serviceType:"NodePort",
//  name:"ballerina-guides-travel-agency-service"
//}
//
//@kubernetes:Deployment {
//  image:"ballerina.guides.io/travel_agency_service:v1.0",
//  name:"ballerina-guides-travel-agency-service"
//}

// Service endpoint
endpoint http:Listener travelAgencyEP {
    port:9090
};

// Client endpoint to communicate with Airline reservation service
endpoint http:Client airlineEP {
    url:"http://localhost:9091/airline"
};

// Client endpoint to communicate with Hotel reservation service
endpoint http:Client hotelEP {
    url:"http://localhost:9092/hotel"
};

// Client endpoint to communicate with Car rental service
endpoint http:Client carRentalEP {
    url:"http://localhost:9093/car"
};

// Travel agency service to arrange a complete tour for a user
@http:ServiceConfig {basePath:"/travel"}
service<http:Service> travelAgencyService bind travelAgencyEP {

    // Resource to arrange a tour
    @http:ResourceConfig {methods:["POST"], consumes:["application/json"], produces:["application/json"]}
    arrangeTour (endpoint client, http:Request inRequest) {
        http:Response outResponse;
        json inReqPayload;

        string resourcePath = "/travel/arrangeTour";
        log:printTrace("Received at : " + resourcePath);
        log:printDebug("Payload at : " + resourcePath + " : ");
        // Try parsing the JSON payload from the request
        match inRequest.getJsonPayload() {
            // Valid JSON payload
            json payload => inReqPayload = payload;
            // NOT a valid JSON payload
            any => {
                outResponse.statusCode = 400;
                outResponse.setJsonPayload({"Message":"Invalid payload - Not a valid JSON payload"});
                _ = client -> respond(outResponse);
                log:printWarn("Invalid payload at : " + resourcePath + " : ");
                done;
            }
        }

        //Extracting data from Request's payload
        json arrivalDate = inReqPayload.ArrivalDate;
        json departureDate = inReqPayload.DepartureDate;
        json fromPlace = inReqPayload.From;
        json toPlace = inReqPayload.To;
        json vehicleType = inReqPayload.VehicleType;
        json location = inReqPayload.Location;

        // If payload parsing fails, send a "Bad Request" message as the response
        if (arrivalDate == null || departureDate == null || fromPlace == null || toPlace == null ||
            vehicleType == null || location == null) {
            outResponse.statusCode = 400;
            outResponse.setJsonPayload({"Message":"Bad Request - Invalid Payload"});
            _ = client -> respond(outResponse);
            log:printWarn("Invalid payload at : " + resourcePath + " : ");
            done;
        }

        // Out request payload for Airline reservation service
        json flightPayload = {"ArrivalDate":arrivalDate, "DepartureDate":departureDate, "From":fromPlace, "To":toPlace};
        // Out request payload for Hotel reservation service
        json hotelPayload = {"ArrivalDate":arrivalDate, "DepartureDate":departureDate, "Location":location};
        // Out request payload for Car rental service
        json vehiclePayload = {"ArrivalDate":arrivalDate, "DepartureDate":departureDate, "VehicleType":vehicleType};

        json jsonFlightResponse;
        json jsonVehicleResponse;
        json jsonHotelResponse;
        json jsonFlightResponseEmirates;
        json jsonFlightResponseAsiana;
        json jsonFlightResponseQatar;

        // Airline reservation
        // Call Airline reservation service and consume different resources in parallel to check different airways
        // Fork - Join to run parallel workers and join the results
        fork {
            // Worker to communicate with airline 'Qatar Airways'
            worker qatarWorker {
                http:Request outReq;
                // Out request payload
                outReq.setJsonPayload(untaint flightPayload);
                // Send a POST request to 'Qatar Airways' and get the results
                http:Response respWorkerQatar = check airlineEP -> post("/qatarAirways", outReq);
                // Reply to the join block from this worker - Send the response from 'Qatar Airways'
                respWorkerQatar -> fork;
            }

            // Worker to communicate with airline 'Asiana'
            worker asianaWorker {
                http:Request outReq;
                // Out request payload
                outReq.setJsonPayload(untaint flightPayload);
                // Send a POST request to 'Asiana' and get the results
                http:Response respWorkerAsiana = check airlineEP -> post("/asiana", outReq);
                // Reply to the join block from this worker - Send the response from 'Asiana'
                respWorkerAsiana -> fork;
            }

            // Worker to communicate with airline 'Emirates'
            worker emiratesWorker {
                http:Request outReq;
                // Out request payload
                outReq.setJsonPayload(untaint flightPayload);
                // Send a POST request to 'Emirates' and get the results
                http:Response respWorkerEmirates = check airlineEP -> post("/emirates", outReq);
                // Reply to the join block from this worker - Send the response from 'Emirates'
                respWorkerEmirates -> fork;
            }
        } join (all) (map airlineResponses) {
            // Wait until the responses received from all the workers running in parallel
            int qatarPrice;
            int asianaPrice;
            int emiratesPrice;

            // Get the response and price for airline 'Qatar Airways'
            if (airlineResponses["qatarWorker"] != null) {
                var resQatar = check <http:Response>(airlineResponses["qatarWorker"]);
                jsonFlightResponseQatar = check resQatar.getJsonPayload();
                match jsonFlightResponseQatar.price {
                    int intVal => qatarPrice = intVal;
                    any otherVals => qatarPrice = -1;
                }
            }

            // Get the response and price for airline 'Asiana'
            if (airlineResponses["asianaWorker"] != null) {
                var resAsiana = check <http:Response>(airlineResponses["asianaWorker"]);
                jsonFlightResponseAsiana = check resAsiana.getJsonPayload();
                match jsonFlightResponseAsiana.price {
                    int intVal => asianaPrice = intVal;
                    any otherVals => asianaPrice = -1;
                }
            }

            // Get the response and price for airline 'Emirates'
            if (airlineResponses["emiratesWorker"] != null) {
                var resEmirates = check <http:Response>(airlineResponses["emiratesWorker"]);
                jsonFlightResponseEmirates = check resEmirates.getJsonPayload();
                match jsonFlightResponseEmirates.price {
                    int intVal => emiratesPrice = intVal;
                    any otherVals => emiratesPrice = -1;
                }
            }

            // Select the airline with the least price
            if (qatarPrice < asianaPrice) {
                if (qatarPrice < emiratesPrice) {
                    jsonFlightResponse = jsonFlightResponseQatar;
                }
            } else {
                if (asianaPrice < emiratesPrice) {
                    jsonFlightResponse = jsonFlightResponseAsiana;
                }
                else {
                    jsonFlightResponse = jsonFlightResponseEmirates;
                }
            }
        }

        // Car rental
        // Call Car rental service and place a booking for a car
        // There's only one car renter, hence, no need of parallel service calls
        http:Request driveSgRequest;
        //Out request payload
        driveSgRequest.setJsonPayload(untaint vehiclePayload, contentType = "application/json");
        // Send a POST request to 'DriveSg' and get the results
        http:Response driveSgResponse = check carRentalEP -> post("/driveSg", driveSgRequest);
        jsonVehicleResponse = check driveSgResponse.getJsonPayload();

        // Hotel reservation
        // Call Hotel reservation service and place a booking for a hotel
        // Again, we only call one hotel service
        http:Request elizabethRequest;
        //Out request payload
        elizabethRequest.setJsonPayload(untaint hotelPayload, contentType = "application/json");
        // Send a POST request to 'Elizabeth' and get the results
        http:Response elizabethResponse = check hotelEP -> post("/elizabeth", elizabethRequest);
        jsonHotelResponse = check elizabethResponse.getJsonPayload();

        // Construct the client response
        json clientResponse = {
            "Flight":jsonFlightResponse,
            "Hotel":jsonHotelResponse,
            "Vehicle":jsonVehicleResponse
        };

        // Response payload
        outResponse.setJsonPayload(untaint clientResponse);
        // Send the response to the client
        _ = client -> respond(outResponse);
    }
}

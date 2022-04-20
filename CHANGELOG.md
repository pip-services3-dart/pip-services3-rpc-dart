# <img src="https://uploads-ssl.webflow.com/5ea5d3315186cf5ec60c3ee4/5edf1c94ce4c859f2b188094_logo.svg" alt="Pip.Services Logo" width="200"> <br/> Remote Procedure Calls for Dart Changelog

## 1.0.0

- Initial version, created by Sergey Seroukhov and Dmitry Levichev

## 1.0.1

- Fix loop in Call method of RestClient, clean code in tests.

## 1.0.2

- Fix close methods of RestService and HttpEndpoint.

## 1.0.3

- Fix work with time, convert to UTC

## 1.0.4

- Add instrument functions in RestOperations

## 1.0.5

- Add safe invocation method in RestOperations

## 1.0.6

- Fix asynchronous authorization issues

## 1.0.7

- Fix service interceptor call and error responding issues

## 1.0.8

- Add swagger OpenAPI support

## 1.1.0

- Migrate RPC from **angel** to **shelf** framework
- Added null-safety support

## 1.1.1

- Added configuration of CORS headers to HttpEndpoint
- Fixed HttpConnectionResolver resolve uri

## 1.1.2

- Fixed params req, res for StatusService and RestOperations

## 1.1.3

- Fixed prepearing empty POST requests

## 1.2.0

- **services**  Added RegRxp supporting to interceptors 
   Examples:
   - the interceptor route **"/dummies"** corresponds to all of this routes **"/dummies"**, **"/dummies/check"**, **"/dummies/test"**
   - the interceptor route **"/dummies$"** corresponds only for this route **"/dummies"**. The routes **"/dummies/check"**, **"/dummies/test"** aren't processing by interceptor
   Please, don't forgot, route in interceptor always automaticaly concateneted with base route, like this **service_base_route + route_in_interceptor**. 
   For example, "/api/v1/" - service base route, "/dummies$" - interceptor route, in result will be next expression - "/api/v1/dummies$"

- **services** Fixed bug with formatting ArraySchema in swagger document

## 1.2.1

- Fixed types of register routes
- Fixed working with auth routes

## 1.2.2

- Fixed Swagger support

## 1.2.3

- Fixed async middleware errors

## 1.2.4

- Fixed swagger data type supports

## 1.2.5

- Fixed request processing for HttpEndpoint
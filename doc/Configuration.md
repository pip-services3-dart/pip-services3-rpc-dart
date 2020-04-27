# Configuration Guide <br/>

Configuration structure follows the 
[standard configuration](https://github.com/pip-services/pip-services3-container-node/doc/Configuration.md) 
structure. 

### <a name="rpc"></a> Remote Procedure Calls

RPC has the following configuration properties by components:

# Configuration parameters fo Commandable HTTP client:

base_route:              base route for remote URI
- connection(s):
  - discovery_key:         (optional) a key to retrieve the connection from connect.idiscovery.html IDiscovery]]
  - protocol:              connection protocol: http or https
  - host:                  host name or IP address
  - port:                  port number
  - uri:                   resource URI or connection string with all parameters in it
- options:
  - retries:               number of retries (default: 3)
  - connect_timeout:       connection timeout in milliseconds (default: 10 sec)
  - timeout:               invocation timeout in milliseconds (default: 10 sec)

# Configuration parameters for HTTP Endpoint:

- connection(s) - the connection resolver"s connections:
    - "connection.discovery_key" - the key to use for connection resolving in a discovery service;
    - "connection.protocol" - the connection"s protocol;
    - "connection.host" - the target host;
    - "connection.port" - the target port;
    - "connection.uri" - the target URI.
- credential - the HTTPS credentials:
    - "credential.ssl_key_file" - the SSL func (c *HttpEndpoint )key in PEM
    - "credential.ssl_crt_file" - the SSL certificate in PEM
    - "credential.ssl_ca_file" - the certificate authorities (root cerfiticates) in PEM

# Configuration parameters for Heartbeat service:

- baseroute:              base route for remote URI (default: "")
- route:                   route to heartbeat operation (default: "heartbeat")
- dependencies:
  - endpoint:              override for HTTP Endpoint dependency
- connection(s):
  - discovery_key:         (optional) a key to retrieve the connection from IDiscovery
  - protocol:              connection protocol: http or https
  - host:                  host name or IP address
  - port:                  port number
  - uri:   

# Configuration parameters for REST service:

- base_route:              base route for remote URI
- dependencies:
  - endpoint:              override for HTTP Endpoint dependency
  - controller:            override for Controller dependency
- connection(s):
  - discovery_key:         (optional) a key to retrieve the connection from IDiscovery
  - protocol:              connection protocol: http or https
  - host:                  host name or IP address
  - port:                  port number
  - uri:                   resource URI or connection string with all parameters in it
- credential - the HTTPS credentials:
  - ssl_key_file:         the SSL private key in PEM
  - ssl_crt_file:         the SSL certificate in PEM
  - ssl_ca_file:          the c

# Configuration parameters for Status REST service

- baseroute:              base route for remote URI
- route:                   status route (default: "status")
- dependencies:
  - endpoint:              override for HTTP Endpoint dependency
  - controller:            override for Controller dependency
- connection(s):
  - discovery_key:         (optional) a key to retrieve the connection from IDiscovery
  - protocol:              connection protocol: http or https
  - host:                  host name or IP address
  - port:                  port number
  - uri:                   resource URI or connection string with all parameters in it

Example:
```yaml
- descriptor: "pip-services-dummies:service:http:default:1.0"
  connection:
    protocol: "http"
    host: "localhost"
    port: 8080
```

For more information on this section read 
[Pip.Services Configuration Guide](https://github.com/pip-services/pip-services3-container-node/doc/Configuration.md#deps)
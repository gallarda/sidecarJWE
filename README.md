# NGINX API Gateway Request Body Transformation with NGINX Unit

A common best practice of API developers is to use an API Gateway between the API server and the API client.  API Gateways add value in many ways.  For example, an API Gateway can act as a load balancer to distribute API traffic across many API servers.  Another feature provided by an API Gateway is transforming the data contained in API requests and responses.

In this project, two proofs of concept will be shown:

1.   *Using NGINX Unit as a sidecar for NGINX Plus* -- NGINX Plus uses JavaScript for data transformation.  NGINX Unit enables other languages to be used like Java, Go, and Python.
2.   *Decrypting a request payload that is protected with JSON Web Encryption (JWE)* -- NGINX Unit will use a Java application to implement JWE encryption and decryption.

** Getting Started **

Docker Compose will be used to deploy three containers:

1.   The NGINX API Gateway
2.   The NGINX Unit Sidecar
3.   A sample API server using "echo-server" -- It outputs a JSON object with the details of the received API request including the body. (Hint: Pipe this output to `jq`)

By default, only the API Gateway is exposed on port 80 to accept inbound API requests.  You can change this port (or expose the other containers) by editing the `docker-compose.yml` file.

After cloning this repo on a system with Docker running, use the following command to start the containers:

.. code-block:: shell
  docker-compose up
|

Keep this terminal open to view the log output from all three containers.  Open a second terminal window to send requests to the exposed API gateway.

For a quick demo, let's encrypt some data into a sample JWE:

.. code-block:: shell
  curl -s 'http://127.0.0.1/encrypt' -H 'Content-Type: text/plain' -d "The true sign of intelligence is not knowledge but imagination." -o test
|

This `curl` creates a file named "test" that contains a JWE with the encrypted version of our data.

Now let's use this JWE as the payload of an encrypted API request:

.. code-block:: shell
  curl -s 'http://127.0.0.1/api/v1/test' -H 'Content-Type: text/plain' -d @test
|

NGINX Plus will receive this request, send the JWE to NGINX Unit for decryption, and then proxy the now clear text payload to the API server for processing.  To protect the API server from malicious requests, NGINX App Protect can be used to inspect the payload first.

APIs don't communicate with text/plain data, they use JSON.  The repo contains a sample JSON payload along with a JWE with this payload already encrypted.  Let's try this JSON payload next:

Send the sample JWE to be decrypted (Notice that the URI, any request headers and the query string are passed to the API server untouched.)

.. code-block:: shell
  curl -sv 'http://127.0.0.1/api/some_version/user/card?yes=no' --header 'Content-Type: application/json' --data @sample.jwe
|

Encrypt the sample JSON

.. code-block:: shell
  curl -s 'http://127.0.0.1/encrypt' --header 'Content-Type: application/json' --data-binary @sample.json
|

If you want to bypass the JWE transformation and send data directly to the API server start your URI with "pass":

.. code-block:: shell
  curl -s 'http://127.0.0.1/pass/api/foo' --header 'Content-Type: application/json' --data-binary @sample.json
|


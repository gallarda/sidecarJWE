function transformBody(r) {

// Grab headers and querystring from original request to proxy to upstream later

   var querystring = (r.variables.args) ? "?"+r.variables.args : "";
   var headers = Object.assign({}, r.headersIn);

// We must remove the original "Content-Length" header because we will replace the request body

   delete headers['Content-Length'];

// First, send request body to Unit for transformation (i.e.: decryption)

    ngx.fetch('http://unit:8000/decrypt.jsp', { method: 'POST', body: r.requestText, headers: headers })
      .then(response => response.text()) 
      .then(payload => {

// Now, proxy request with transformed request body to upstream (Using second server block for NGINX App Protect)

        ngx.fetch('http://127.0.0.1:8080'+r.uri+querystring, { method: r.method, body: payload, headers: headers })
            .then(reply => {

// Copy headers from the upstream "reply" to include in your response to the original request (while deleting duplicates)

               for (var h in reply.headers) {
                   r.headersOut[h]=reply.headers.get(h);
               }
               delete r.headersOut['Date'];
               delete r.headersOut['Connection'];
               delete r.headersOut['Server'];

               return reply.text();
            }) 

// All done!

            .then(body => r.return(200, body))
      })

      .catch(e => r.return(500, e));
}

export default {transformBody}

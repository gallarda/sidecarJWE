<%@ page language="java" contentType="application/jwe; charset=utf-8" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="org.jose4j.jwe.JsonWebEncryption" %>
<%@ page import="org.jose4j.jwe.KeyManagementAlgorithmIdentifiers" %>
<%@ page import="org.jose4j.jwe.ContentEncryptionAlgorithmIdentifiers" %>
<%@ page import="java.security.KeyFactory" %>
<%@ page import="java.security.spec.X509EncodedKeySpec" %>
<%@ page import="java.security.interfaces.RSAPublicKey" %>
<%@ page import="java.util.Base64" %>
<%@ page import="java.util.stream.Collectors" %>
<%

    String body = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) 
    {
       body = request.getReader().lines().collect(Collectors.joining(System.lineSeparator()));
    }

    KeyFactory keyFactory = KeyFactory.getInstance("RSA");
    byte[] binaryKey = Base64.getDecoder().decode("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoahUIoWw0K0usKNuOR6H4wkf4oBUXHTxRvgb48E+BVvxkeDNjbC4he8rUWcJoZmds2h7M70imEVhRU5djINXtqllXI4DFqcI1DgjT9LewND8MW2Krf3Spsk/ZkoFnilakGygTwpZ3uesH+PFABNIUYpOiN15dsQRkgr0vEhxN92i2asbOenSZeyaxziK72UwxrrKoExv6kc5twXTq4h+QChLOln0/mtUZwfsRaMStPs6mS6XrgxnxbWhojf663tuEQueGC+FCMfra36C9knDFGzKsNa7LZK2djYgyD3JR/MB/4NUJW/TqOQtwHYbxevoJArm+L5StowjzGy+/bq6GwIDAQAB");
    RSAPublicKey publicKey = (RSAPublicKey)keyFactory.generatePublic(new X509EncodedKeySpec(binaryKey));  		
    JsonWebEncryption jwe = new JsonWebEncryption();
    jwe.setPayload(body);
    jwe.setAlgorithmHeaderValue(KeyManagementAlgorithmIdentifiers.RSA_OAEP_256);
    jwe.setEncryptionMethodHeaderParameter(ContentEncryptionAlgorithmIdentifiers.AES_128_GCM);
    jwe.setKey(publicKey);
    jwe.setKeyIdHeaderValue("12345");
    String jweCompact = jwe.getCompactSerialization();
    out.println(jweCompact);
    System.out.println("***** Encrypting payload: "+jwe.getHeader()+"\n"+body+"\n***** JWE: "+jweCompact);
    response.setHeader("X-JWE-Header", jwe.getHeader());
%>

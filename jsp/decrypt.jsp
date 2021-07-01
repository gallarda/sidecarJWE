<%@ page language="java" contentType="application/json; charset=utf-8" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="org.jose4j.jwe.JsonWebEncryption" %>
<%@ page import="org.jose4j.jwe.KeyManagementAlgorithmIdentifiers" %>
<%@ page import="org.jose4j.jwe.ContentEncryptionAlgorithmIdentifiers" %>
<%@ page import="java.security.KeyFactory" %>
<%@ page import="java.security.spec.PKCS8EncodedKeySpec" %>
<%@ page import="java.security.interfaces.RSAPrivateKey" %>
<%@ page import="java.util.Base64" %>
<%@ page import="java.util.stream.Collectors" %>
<%

    String body = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) 
    {
       body = request.getReader().lines().collect(Collectors.joining(System.lineSeparator()));
    }

    KeyFactory keyFactory = KeyFactory.getInstance("RSA");
    byte[] binaryKey = Base64.getDecoder().decode("MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQChqFQihbDQrS6wo245HofjCR/igFRcdPFG+BvjwT4FW/GR4M2NsLiF7ytRZwmhmZ2zaHszvSKYRWFFTl2Mg1e2qWVcjgMWpwjUOCNP0t7A0PwxbYqt/dKmyT9mSgWeKVqQbKBPClne56wf48UAE0hRik6I3Xl2xBGSCvS8SHE33aLZqxs56dJl7JrHOIrvZTDGusqgTG/qRzm3BdOriH5AKEs6WfT+a1RnB+xFoxK0+zqZLpeuDGfFtaGiN/rre24RC54YL4UIx+trfoL2ScMUbMqw1rstkrZ2NiDIPclH8wH/g1Qlb9Oo5C3AdhvF6+gkCub4vlK2jCPMbL79urobAgMBAAECggEBAJC3bSI+hmw5LPwKQkk2ELXpXDbbZSojsj8zK1x3iPspNRe/pKQ8WOPlmOTVleSp7WhHl0tY/NhN++ccYVjB18r42HnD0/X6cEfzPYFfJ/R64dmp06Uw/dw7etsqVt8g7CcwZ0562LtYsFkYASqxGGOOqgGSKwNsQMJ5tl+7hkdYYIZKg6dFao95G0gs9V8nwrOvy3oQcLcRyMofEYqcuNKduJqDgG4MVcN68U/75bd1FXuFjtyZCTs5aVH/ik1SNj7YJvnQEcUxLRPonfuDia9IfivlRbN1Up3VUyM50sX8q4/CCy+jBv1L/GALu1SC0gd5TltPOfuKhNw84K044MkCgYEA1r52Xk46c+LsfB5P442p7atdPUrxQSy4mti/tZI3Mgf2EuFVbUoDBvaRQ+SWxkbkmoEzL7JXroSBjSrK3YIQgYdMgyAEPTPjXv/hI2/1eTSPVZfzL0lffNn03IXqWF5MDFuoUYE0hzb2vhrlN/rKrbfDIwUbTrjjgieRbwC6Cl0CgYEAwLb35x7hmQWZsWJmB/vle87ihgZ19S8lBEROLIsZG4ayZVe9Hi9gDVCOBmUDdaDYVTSNx/8Fyw1YYa9XGrGnDew00J28cRUoeBB/jKI1oma0Orv1T9aXIWxKwd4gvxFImOWr3QRL9KEBRzk2RatUBnmDZJTIAfwTs0g68UZHvtcCgYBkr5jATt2JSHSpHW1HvDxYe2iUPHcxn85OjCIW+B95DdKKt6xeOb2BnkouExe+j67P4pQlYPFLmkVD8zR692jV0qJFONXD/Hg3KrJc8zmdQs+RylTzbuuelnMAkql2FYCCqtcYoAQJAfRe3i1rOeOd3/NWkCZlmrrRY8wEx8py4QKBgA6tIH4CdQ3RRl4i70BGZ7ihDdFFJrCQcZI8nXN4+GWHQYjEQMvOsdLxwo8sHDJWGIOMqAuGGWvYTVXLI6gNxXoi9fa5PIOkJ9vU7dHI/Kqshac/bzQwVHwgIiVXhEjoyQ2T2B3R2PL9W/qPmdl+bby8fkwnpH+6Mcnig1Kilo4rAoGAVIMpMYbPf47dT1w/zDUXfPimsSegnMOA1zTaX7aGk/8urY6R8+ZW1FxU7AlWAyLWybqq6t16VFd7hQd0y6flUK4SlOydB61gwanOsXGOAOv82cHq0E3eL4HrtZkUuKvnPrMnsUUFlfUdybVzxyjz9JF/XyaY14ardLSjf4L/FNY=");
    RSAPrivateKey privateKey = (RSAPrivateKey)keyFactory.generatePrivate(new PKCS8EncodedKeySpec(binaryKey));  		
    JsonWebEncryption jwe = new JsonWebEncryption();
    jwe.setAlgorithmHeaderValue(KeyManagementAlgorithmIdentifiers.RSA_OAEP_256);
    jwe.setEncryptionMethodHeaderParameter(ContentEncryptionAlgorithmIdentifiers.AES_128_GCM);
    jwe.setKey(privateKey);
    jwe.setCompactSerialization(body);
    String payload = jwe.getPayload();
    out.println(payload);
    System.out.println("***** Decrypted payload: "+jwe.getHeader()+"\n"+payload);
    response.setHeader("X-JWE-Header: ", jwe.getHeader());
%>

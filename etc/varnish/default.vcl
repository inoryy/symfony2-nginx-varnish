backend default {
    .host = "127.0.0.1";
    .port = "8080";
}

sub vcl_recv {
    set req.http.Surrogate-Capability = "abc=ESI/1.0";

    if (req.http.x-forwarded-for) {
        set req.http.X-Forwarded-For =
        req.http.X-Forwarded-For ", " client.ip;
    } else {
        set req.http.X-Forwarded-For = client.ip;
    }
}

sub vcl_fetch {
    if (beresp.http.Surrogate-Control ~ "ESI/1.0") {
        unset beresp.http.Surrogate-Control;
        esi;
    }

    if (!beresp.cacheable) {
        return (pass);
    }
    
    if (beresp.http.Set-Cookie) {
        return (pass);
    }
    
    return (deliver);
}
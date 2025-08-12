# Squid proxy SSL-Bump with -http-violations enabled

Simple squid MITM proxy sample image.
The Dockerfile first download the needed packages to run Squid then compile squid with ssl-bump enabled. 

Various configure options has been removed to keep the executable short. Also, Please take in consideration that it compiles from source code, so it'll take some time to finish! 

By default, squid doesn't allow to optimize HTTP headers, therefore, Squid will never be really transparent. But we can achieve that intented beheavior just changing the configure options on compile time. 

The container will create a self-signed certificate and will listen on 3129 port. It'll then encrypt/decrypt ssl traffic.

Please, be aware that changing HTTP_headers could break normal web browsing behavior.

## Some considerations

Many of Squid proxy features has been disabled to keep the image small. Also consider using other tools rather than Squid for proxing since it's not suited for most current use cases, also consider it's just an example how to run Squid under Docker. 

## How to run this image

First build the image:
```
docker build -t squid .
```

Then:

```
docker run -d --name squid -p 3129:3129 squid 
```






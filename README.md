# Squid proxy SSL-Bump with -http-violations enabled

Simple squid MITM proxy sample image.
The Dockerfile first download the needed packages to run Squid then compile squid with ssl-bump enabled. 

Various configure options has been removed to keep the executable short. Also, Please take in consideration that it compiles from source code, so it'll take some time to finish! 

By default, squid doesn't allow to optimize HTTP headers, therefore, Squid will never be really transparent. We can achieve this behavior just changing the configure options on compile time. 

The container will create a self-signed certificate and will listen on 3129 port. It'll then encript/decript ssl traffic.

Please, be aware that changing HTTP_headers will break normal web browsing at some point if not choosing headers carefully. Also some web sites could ban your ip if find bogus HTTP_headers.  

## Some considerations

This is a sample image. It's not meant to be in any production enviroment. Also Many of its features has been disabled to keep the code small.

## How to run this image

First build the image:
```
docker build -t squid .
```

Then run it:

```
docker run -d --name squid -p 3129:3129 
```

FROM debian:12-slim

RUN  apt update && apt install -y build-essential openssl libssl-dev ca-certificates wget lynx nano curl perl libcap-dev \
	&& apt clean \ 
	&& mkdir /opt/squid \
	&& wget -q http://www.squid-cache.org/Versions/v6/squid-6.3.tar.gz -O /opt/squid/squid.tgz \ 
	&& tar xzf /opt/squid/squid.tgz --strip-components=1 -C /opt/squid/ && cd /opt/squid \
		# optional download c-icap server and squid-clamav to run with Clamav Antivirus. I recommend running Clamav not in the same machine.
		# && wget -q https://github.com/darold/squidclamav/archive/v7.2.tar.gz -O /opt/sclamav.tgz \
		# && wget -q http://sourceforge.net/projects/c-icap/files/c-icap/0.5.x/c_icap-0.5.10.tar.gz -O /opt/c-icap.tgz \ 
	&& ./configure --prefix=/usr \
	--sysconfdir=/etc/squid \
	--datadir=/usr/share/squid \
	--libexecdir=/usr/lib/squid \
	--localstatedir=/var \
	--with-logdir=/var/log/squid \
	--with-default-user=proxy \ 
	--with-pidfile=/var/run/squid.pid \
		--disable-strict-error-checking \
		--enable-openssl \
		--enable-ssl \
		--enable-ssl-crtd \
		#--enable-icap-client \
		--enable-http-violations \
		--with-large-files \
		--enable-follow-x-forwarded-for \
		--disable-optimizations \
		--disable-wccp \
		--disable-wccpv2 \
		--disable-snmp \
		--disable-htcp \
		--enable-err-languages=English \
		--disable-translation \ 
		--disable-internal-dns \
		#--disable-auto-locale \ 
		--disable-ident-lookups \ 
		--disable-mit \
		--enable-log-daemon-helpers="DB,file" \
		--with-openssl \
	&& make all && make install 

COPY squid.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/squid.sh

# optional
#EXPOSE 3128
EXPOSE 3129

WORKDIR /etc/squid
ENTRYPOINT ["/usr/local/bin/squid.sh"] 




#!/bin/bash

set -e

CHOWN=$(/usr/bin/which chown)
SQUID=$(/usr/bin/which squid)

SQUID_LIB=/usr/lib/squid
SQUID_CONF=/etc/squid
SQUID_ADD=/etc/squid/squid.conf

PID=/var/run/squid.pid

sanitizeEverything() {
	echo "Starting Squid..."
 
	if [ -f $PID ]; then
    	rm -rf $PID
	fi

	if [ -f $SQUID_LIB/ssl_db ]; then
		rm -rf $SQUID_LIB/ssl_db 
	fi

	"$CHOWN" -R proxy:proxy /var/log/squid 
}

loadSsl() {

	openssl req -new -newkey rsa:2048 -nodes -days 3650 -x509 -keyout $SQUID_CONF/myCA.pem -out $SQUID_CONF/myCA.crt \
 	-subj "/C=AR/ST=Cordoba/L=Salsipuedes/O=General/OU=PunkRebellion.LTD/CN=comandosuicida.local"

	# Browsers won't let you browse websites without this file. Import certificate into your browser. 
	openssl x509 -in $SQUID_CONF/myCA.crt -outform DER -out $SQUID_CONF/myCA.der
	

	$SQUID_LIB/security_file_certgen -c -s $SQUID_LIB/ssl_db -M 4MB
	
	sleep 1 

	echo " " >>  $SQUID_ADD

	echo "# ------ Added config ---------#" >> $SQUID_ADD
	echo " " >> $SQUID_ADD
	echo "always_direct allow all" >> $SQUID_ADD
	echo "ssl_bump bump all" >> $SQUID_ADD
	echo "sslproxy_cert_error allow all" >> $SQUID_ADD
	
	echo "http_port 3129 ssl-bump generate-host-certificates=on dynamic_cert_mem_cache_size=4MB cert=$SQUID_CONF/myCA.crt key=$SQUID_CONF/myCA.pem" >> $SQUID_ADD
	echo "sslcrtd_program $SQUID_LIB/security_file_certgen -s $SQUID_LIB/ssl_db -M 4MB" >> $SQUID_ADD

	echo " " >> $SQUID_ADD

	echo "#------ Header settings -------- #" >> $SQUID_ADD
	echo "httpd_suppress_version_string on" >> $SQUID_ADD

	echo " " >> $SQUID_ADD 

	echo "request_header_access Via deny all" >> $SQUID_ADD
	echo "request_header_access Forwarded-For deny all" >> $SQUID_ADD
	echo "request_header_access X-Forwarded-For deny all" >> $SQUID_ADD
	echo "request_header_access Referer deny all" >> $SQUID_ADD

	echo " " >> $SQUID_ADD

	echo "#--------  We accept everything else ---------- #" >> $SQUID_ADD
	echo "request_header_access All allow all" >> $SQUID_ADD

	# Example how to customize headers: 
	# request_header_replace User-Agent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.82 Safari/537.36' 
	# request_header_access From deny all
	# request_header_access Cookie deny all

	# Reply Headers
	## Deny follwing replies for anonymous browsing
	echo "reply_header_access Via deny all" >> $SQUID_ADD
	
	# reply_header_access Server deny all
	# reply_header_access WWW-Authenticate deny all
	# reply_header_access Link deny all
	# reply_header_access Cookie deny all

}

startCache() {
	echo "Creating cache folder..."
	"$SQUID" -z

	sleep 3
}

startSquid() {

	sanitizeEverything
	loadSsl
	startCache

	exec "$SQUID" -NYCd 1 -f $SQUID_ADD
}

startSquid

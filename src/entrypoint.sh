#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

DEBUG="${DEBUG:-}"
CN=${CN:-localhost}
PUID=${PUID:-5000}
PGID=${PGID:-5000}

LOGFILE="/data/logs/dovecot.log"
OPENSSL_CONF="/config/dovecot-openssl.cnf"
CERTFILE="/config/cert.pem"
KEYFILE="/config/key.pem"

[ "$DEBUG" == 'true' ] && set -x

[ ! -d /config ] && mkdir /config
[ ! -d /data ] && mkdir /data
[ ! -d /data/vmail ] && mkdir /data/vmail
[ ! -d /data/logs ] && mkdir /data/logs

[ ! -e /config/passwd ] && \
    cp /etc/dovecot/passwd.default /config/passwd

groupadd \
    --gid "${PGID}" \
    vmail

useradd \
    --home-dir "/data/vmail" \
    --gid vmail \
    --no-create-home \
    --uid "${PUID}" \
    --shell "/usr/sbin/nologin" \
    vmail

chown -R vmail:vmail /data/vmail
echo "User vmail(uid:$(id -u vmail), gid:$(id -g vmail))"

echo "hello world" >> ${LOGFILE}

[ ! -e ${OPENSSL_CONF} ] && \
    cat /etc/dovecot/dovecot-openssl.cnf | sed "s/CN=.*/CN=${CN}/g" > ${OPENSSL_CONF}

[ ! -e ${CERTFILE} ] && \
    openssl req -new -x509 -nodes -config ${OPENSSL_CONF} -out ${CERTFILE} -keyout ${KEYFILE} -days 365 && \
    openssl x509 -subject -fingerprint -noout -in ${CERTFILE} &&
    chmod 0400 ${KEYFILE} ${CERTFILE}

exec tail -f ${LOGFILE} &
dovecot -F
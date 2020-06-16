FROM ubuntu:18.04

MAINTAINER simojenki

RUN apt update && \
    apt install -y \
        dovecot-core \
        dovecot-imapd && \
    rm -Rf /etc/dovecot

ADD src/entrypoint.sh /

ADD src/etc /etc

EXPOSE 993

VOLUME /data
VOLUME /config

CMD ["/entrypoint.sh"]

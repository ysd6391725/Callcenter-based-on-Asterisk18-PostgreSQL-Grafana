FROM alpine:latest

MAINTAINER Sergey Yakovenko <ysd6391725@gmail.com>

COPY files/repo/repositories /etc/apk/repositories

RUN apk add --update --allow-untrusted \
      bash lame unixodbc psqlodbc libgcc libstdc++ libcap libcurl libuuid \
      asterisk asterisk-pgsql asterisk-odbc\
      asterisk-sample-config \
&& asterisk -U asterisk \
&& chown -R asterisk:asterisk /var/run/asterisk \
                                  /etc/asterisk/ \
                                  /var/lib/asterisk \
                                  /var/log/asterisk \
                                  /var/spool/asterisk \
                                  /usr/lib/asterisk/ \
                                  /var/spool/asterisk/monitor/ \
&&  rm -rf /var/cache/apk/* \
           /tmp/* \
           /var/tmp/*

COPY files/* /etc/asterisk/
COPY files/odbc/* /etc/
COPY files/sounds/* /var/lib/asterisk/sounds/

USER asterisk
CMD /usr/sbin/asterisk -f


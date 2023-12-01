FROM alpine:latest

RUN apk update && apk add apache2 && apk add cacti && apk add php
COPY httpd.conf /etc/apache2/httpd.conf
EXPOSE 80


CMD ["httpd", "-D", "FOREGROUND"]
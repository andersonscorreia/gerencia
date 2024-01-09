#!/bin/bash

apt install -y curl
curl -O https://dl.influxdata.com/influxdb/releases/influxdb2_2.7.4-1_amd64.deb
dpkg -i influxdb2_2.7.4-1_amd64.deb

service influxdb start

ARG1="127.0.0.1:8087"

sed -i "s|^ExecStart=/usr/bin/influxd.*|ExecStart=/usr/bin/influxd $ARG1|" /lib/systemd/system/influxdb.service

systemctl daemon-reload

service influxdb restart

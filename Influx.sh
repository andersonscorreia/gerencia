#!/bin/bash

curl -O https://dl.influxdata.com/influxdb/releases/influxdb2_2.7.4-1_arm64.deb
dpkg -i influxdb2_2.7.4-1_arm64.deb

service influxdb start

ARG1="127.0.0.1:8087"

ExecStart=/usr/bin/influxd $ARG1

service influxdb restart

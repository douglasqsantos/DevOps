#!/bin/bash


[ -f "/run/nologin" ] && rm -rf /run/nologin

/usr/sbin/sshd -D

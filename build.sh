#!/bin/bash

docker rmi --force simojenki/dovecot:latest
docker build --pull -t simojenki/dovecot:latest .

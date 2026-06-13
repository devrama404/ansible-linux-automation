#!/bin/bash

DATE=$(date +%F)

mkdir -p /home/devrama/backups

tar -czf /home/devrama/backups/etc-$DATE.tar.gz /etc

#!/bin/bash

echo "===== HOSTNAME ====="
hostname

echo
echo "===== OS ====="
grep PRETTY_NAME /etc/os-release

echo
echo "===== UPTIME ====="
uptime

echo
echo "===== OPEN PORTS ====="
ss -tulpn

echo
echo "===== FIREWALL ====="
ufw status

echo
echo "===== FAIL2BAN ====="
systemctl is-active fail2ban

echo
echo "===== DISK ====="
df -h

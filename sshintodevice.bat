@echo off
echo waiting before ssh
timeout /t 25 >NUL
echo mounting partitions
plink -P 2022 -pw alpine -batch root@127.0.0.1 mount.sh
echo 

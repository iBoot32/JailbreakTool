PATH="/bin:/sbin:/usr/bin:/usr/local/bin:/usr/sbin"
export PATH
sleep 2

echo
echo "-----------------------------"
echo
echo JailbreakTool by iBoot32
echo
echo "-----------------------------"
echo
echo Mounting partitions
echo
mount.sh
echo
echo Moving patched fstab
mv /mnt1/etc/fstab /mnt1/etc/fstab_old
mv /bin/fstab /mnt1/etc/fstab
echo Moving patched SpringBoard plist
mv /mnt1/System/Library/CoreServices/SpringBoard.app/English.lproj/SpringBoard.strings /mnt1/System/Library/CoreServices/SpringBoard.app/English.lproj/SpringBoard.strings.old
mv /bin/SpringBoard.strings /mnt1/System/Library/CoreServices/SpringBoard.app/English.lproj/SpringBoard.strings
echo Verbose Booting
nvram boot-args=" -v"
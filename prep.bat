@echo off

SET workdir=%cd%

if exist "C:\JBWork\" del /f /s /q "C:/JBWork" 1>nul && rmdir /s /q "C:/JBWork"
if not exist "C:\JBWork\" cd C:/ && mkdir JBWork && cd %workdir%

echo.
echo.
echo Downloading wget
powershell.exe -Command (new-object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/iBoot32/JailbreakTool/master/wget.exe', 'C:/JBWork/wget.exe') 2> nul
cd "C:/JBWork"

echo Downloading 7z.exe
wget.exe https://raw.githubusercontent.com/iBoot32/JailbreakTool/master/7z.exe 2> nul

echo Downloading 7z.dll
wget.exe https://raw.githubusercontent.com/iBoot32/JailbreakTool/master/7z.dll 2> nul

echo Downloading Binaries
wget.exe https://github.com/iBoot32/JailbreakTool/archive/master.zip 2> nul

echo Unzipping binaries
7z.exe x master.zip > nul 2>&1
cd JailbreakTool-master
move * .. > nul 2>&1
move otherfiles .. > nul 2>&1
cd ..
del master.zip
del /f /s /q "JailbreakTool-master" 1>nul && rmdir /s /q "JailbreakTool-master" 

echo Downloading Ramdisk... 
echo.
"C:/JBWork/partialzip.exe" "http://appldnld.apple.com/iOS5.1.1/041-4347.20120427.o2yov/iPhone2,1_5.1.1_9B206_Restore.ipsw" "038-4349-020.dmg" "C:/JBWork/ramdisk.dmg"

echo.
echo Decrypting Ramdisk
echo.
xpwntool ramdisk.dmg ramdisk.dmg.dec -k 7af575ca159ba58b852dfe1c6f30c68220a7a94be47ef319ce4f46ba568b7a81 -iv 26ec90f47073acaa0826c55bdeddf4bb

echo.
echo Enlarging Ramdisk
echo.
hfsplus ramdisk.dmg.dec grow 40000000

echo.
echo Adding ssh service to Ramdisk
echo.
hfsplus ramdisk.dmg.dec untar ssh.tar "/"

echo.
echo Rebuilding Ramdisk
echo.
move ramdisk.dmg ramdisk.dmg.orig
xpwntool ramdisk.dmg.dec ramdisk.dmg -t ramdisk.dmg.orig -k 7af575ca159ba58b852dfe1c6f30c68220a7a94be47ef319ce4f46ba568b7a81 -iv 26ec90f47073acaa0826c55bdeddf4bb

echo ramdisk built
echo.
echo.

echo Downloading iBEC and iBSS
"C:/JBWork/partialzip.exe" "http://appldnld.apple.com/iOS5.1.1/041-4347.20120427.o2yov/iPhone2,1_5.1.1_9B206_Restore.ipsw" "Firmware/dfu/iBSS.n88ap.RELEASE.dfu" "C:/JBWork/ibss.dfu"
"C:/JBWork/partialzip.exe" "http://appldnld.apple.com/iOS5.1.1/041-4347.20120427.o2yov/iPhone2,1_5.1.1_9B206_Restore.ipsw" "Firmware/dfu/iBEC.n88ap.RELEASE.dfu" "C:/JBWork/ibec.dfu"

echo Decrypting iBEC and iBSS
xpwntool ibec.dfu ibec.dfu.dec -k 677be330d799ffafad651b3edcb34eb787c2d6c56c07e6bb60a753eb127ffa75 -iv 1fe15472e85b169cd226ce18fe6de524
xpwntool ibss.dfu ibss.dfu.dec -k 36782ee3df23e999ffa955a0f0e0872aa519918a256a67799973b067d1b4f5e0 -iv 0cbb6ea94192ba4c4f215d3f503279f6

echo patching iBEC and iBSS
fuzzy_patcher --patch --delta ibec.patch --orig ibec.dfu.dec --patched ibec.dfu.dec.p
fuzzy_patcher --patch --delta ibss.patch --orig ibss.dfu.dec --patched ibss.dfu.dec.p


echo reencrypting iBEC and iBSS
move ibec.dfu ibec.dfu.orig
move ibss.dfu ibss.dfu.orig
xpwntool ibec.dfu.dec.p ibec.dfu -t ibec.dfu.orig -iv 1fe15472e85b169cd226ce18fe6de524 -k 677be330d799ffafad651b3edcb34eb787c2d6c56c07e6bb60a753eb127ffa75
xpwntool ibss.dfu.dec.p ibss.dfu -t ibss.dfu.orig -iv 0cbb6ea94192ba4c4f215d3f503279f6 -k 36782ee3df23e999ffa955a0f0e0872aa519918a256a67799973b067d1b4f5e0

echo downloading devicetree
"C:/JBWork/partialzip.exe" "http://appldnld.apple.com/iOS5.1.1/041-4347.20120427.o2yov/iPhone2,1_5.1.1_9B206_Restore.ipsw" "Firmware/all_flash/all_flash.n88ap.production/DeviceTree.n88ap.img3" "C:/JBWork/devicetree.img3"

echo downloading kernelcache
"C:/JBWork/partialzip.exe" "http://appldnld.apple.com/iOS5.1.1/041-4347.20120427.o2yov/iPhone2,1_5.1.1_9B206_Restore.ipsw" "kernelcache.release.n88" "C:/JBWork/kernelcache.release.n88"

echo decrypting kernelcache
xpwntool kernelcache.release.n88 kern.dec -k 0cc1dcb2c811c037d6647225ec48f5f19e14f2068122e8c03255ffe1da25dec3 -iv 0dc795a64cb411c21033f97bceb96546

echo patching kernelcache
fuzzy_patcher --patch --orig kern.dec --delta kernelcache.patch --patched kern.dec.p

echo reencrypting kernelcache
move kernelcache.release.n88 kern.orig
xpwntool kern.dec.p kernelcache.release.n88 -t kern.orig -k 0cc1dcb2c811c037d6647225ec48f5f19e14f2068122e8c03255ffe1da25dec3 -iv 0dc795a64cb411c21033f97bceb96546

echo tetherbooting the device
irec -e
echo Sending iBSS
irecovery -f ibss.dfu
echo Sending iBEC
irecovery -f ibec.dfu
timeout /t 15 >NUL
echo Sending devicetree
irecovery -f devicetree.img3
irecovery -c devicetree
timeout /t 6 >NUL
echo Sending ramdisk
irecovery -f ramdisk.dmg
timeout /t 5 >NUL
irecovery -c ramdisk 0x90000000
timeout /t 6 >NUL
echo Sending kernelcache
irecovery -f kernelcache.release.n88
timeout /t 5 >NUL
echo Booting kernelcache to start ssh service
irecovery -c bootx

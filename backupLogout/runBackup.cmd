@echo off
pushd \\192.168.15.204\pcs\scripts\bkpSetup
powershell.exe -ExecutionPolicy Bypass -NoProfile -File .\backupLogout\setup.ps1
popd

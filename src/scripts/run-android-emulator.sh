setup-environment
handle-shutdown

run-test-emulator & :
wait-for-boot

adb devices
adb shell settings put global adb_wifi_enabled 1
adb devices
adb tcpip 5554
echo "Started android emulator. PID: $!"

sleep inf

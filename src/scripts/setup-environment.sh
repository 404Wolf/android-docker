mkdir -p /tmp

adb keygen "/.android/adbkey"
chmod 600 "/.android/adbkeys/adbkey"
chmod 644 "/.android/adbkeys/adbkey.pub"
export ADB_VENDOR_KEYS="/.android"
echo "Generated key pair for adb and set permissions"


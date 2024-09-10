mkdir -p /tmp

adb keygen "/.android/adbkey"
chmod 600 "/.android/adbkeys/adbkey"
chmod 644 "/.android/adbkeys/adbkey.pub"
export adb_vendor_keys="/.android"
/nix/store/6m9a4il11bb81zzy8arvvqbf1b34lxaa-android-emulator/bin/android-emulator
export ANDROID_SDK_ROOT=/nix/store/ziwjy7xfy9fxypfx9zj2k2zn7c7i7fvd-androidsdk/libexec/android-sdk

echo "Generated key pair for adb and set permissions"


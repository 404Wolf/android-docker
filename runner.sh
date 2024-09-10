podman run -d --name android-emulator --replace \
    -p 5556:5555 \
    --device /dev/kvm \
    localhost/android-emulator:latest

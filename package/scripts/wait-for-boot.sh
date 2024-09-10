# Function to check if the emulator is booted
is_booted() {
    adb -e shell getprop sys.boot_completed | grep -q "1"
}

echo "Starting emulator..."

# Wait for the emulator to be ready
while ! is_booted; do
    echo "Waiting for emulator to boot..."
    sleep 3
done
sleep 2

# Log that the emulator is ready
echo "Emulator is ready!"

# Function to check if the emulator is booted
is_booted() {
    adb -e shell getprop sys.boot_completed | grep -q "1"
}

echo "Starting emulator..."

# Wait for the emulator to be ready
while ! is_booted; do
    echo "Waiting for emulator to boot..."
    sleep 5
done

echo "Emulator is ready!"

# Optional: Wait a bit more to ensure all services are up
sleep 10

echo "Emulator is fully booted and ready to use."

function shutdown() {
    echo "SIGTERM is received! Clean-up will be executed if needed!"
    PROCESS_ID=$(pgrep -f "start device")
    kill "$PROCESS_ID"
    sleep 10
}
trap shutdown SIGTERM

# shellcheck disable=SC2034


start_scrcpy() {
    local VIDEO_PORT="$1"
    local AUDIO_PORT="$2"
    local DATA_PORT="$3"
    local start_time
    local timeout

    echo "Starting scrcpy on device with:"
    echo "Video port: $VIDEO_PORT"
    echo "Audio port: $AUDIO_PORT"
    echo "Data port: $DATA_PORT"

    if ! adb push "$SCRCPY_SERVER_PATH" /data/local/tmp/scrcpy-server.jar; then
        echo "Failed to push scrcpy server to device" >&2
        return 1
    fi
    echo "Pushed scrcpy server to device"

    if ! adb forward tcp:"$VIDEO_PORT" localabstract:scrcpy; then
        echo "Failed to forward port" >&2
        return 1
    fi
    echo "Forwarded port"

    adb shell "CLASSPATH=/data/local/tmp/scrcpy-server.jar \
      app_process / com.genymobile.scrcpy.Server 2.6.1 \
      tunnel_forward=true \
      audio=false \
      control=false \
      cleanup=false \
      raw_stream=true \
      max_size=1920 \
      video_bit_rate=35000000 \
      video_codec_options=bitrate-mode=4,latency=0 \
      max_fps=30" &

    echo "Started launching scrcpy"

    start_time=$(date +%s)
    timeout=60
    while ! tail -n1 "$SCRCPY_STATUS_FILE" 2>/dev/null | grep -q "^\[server"; do
        echo "Waiting for scrcpy to ready up"
        sleep 1
        if (( $(date +%s) - start_time > timeout )); then
            echo "Timeout waiting for scrcpy to start" >&2
            return 1
        fi
    done

    echo "scrcpy is ready"
}

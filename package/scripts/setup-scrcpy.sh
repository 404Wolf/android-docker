start_scrcpy() {
    local SCRCPY_SERVER_PATH="$1"
    local PORT="$2"

    adb push "$SCRCPY_SERVER_PATH" /data/local/tmp/scrcpy-server.jar
    echo "Pushed scrcpy server to device"

    adb forward tcp:"$PORT" localabstract:scrcpy
    echo "Forwarded port"

    adb shell "CLASSPATH=/data/local/tmp/scrcpy-server.jar \
    app_process / com.genymobile.scrcpy.Server 2.5 \
    tunnel_forward=true \
    audio=false \
    control=false \
    cleanup=false \
    raw_stream=true \
    max_size=1920 \
    video_bit_rate=35000000 \
    video_codec_options=bitrate-mode=4,latency=0 \
    max_fps=30"

    echo "Started running scrcpy"
}

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <scrcpy_server_path> <port>"
    exit 1
fi

start_scrcpy "$1"

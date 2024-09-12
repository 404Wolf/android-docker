IP="127.0.0.1"

start_ffmpeg() {
    input_port="$1"
    output_port="$2"
    ffmpeg \
        -i "tcp://$IP:$input_port" \
        -c:v copy \
        -an \
        -fflags nobuffer \
        -f rtp "rtp://$IP:$output_port" \
        -sdp_file video.sdp
}

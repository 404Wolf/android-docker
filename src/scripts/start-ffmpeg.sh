IP="127.0.0.1"

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_port> <output_port>"
    exit 1
fi

input_port="$1"
output_port="$2"

ffmpeg \
    -i "tcp://$IP:$input_port" \
    -c:v copy \
    -an \
    -fflags nobuffer \
    -f rtp "rtp://$IP:$output_port" \
    -sdp_file video.sdp


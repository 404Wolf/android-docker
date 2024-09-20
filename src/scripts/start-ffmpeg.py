import argparse

from ffmpy import FFmpeg


def start_ffmpeg(input_port, output_port, sdp_file="video.sdp", **kwargs):
    IP = "127.0.0.1"
    inputs = {f"tcp://{IP}:{input_port}": None}
    outputs = {
        f"rtp://{IP}:{output_port}": f"-c:v copy -an -f rtp -sdp_file {sdp_file}"
        + " ".join([f"-{key} {value}" for key, value in kwargs.items()])
    }

    ff = FFmpeg(inputs=inputs, outputs=outputs)
    ff.run()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Start FFmpeg with parameters.")
    parser.add_argument("input_port", type=int, help="Input TCP port number")
    parser.add_argument("output_port", type=int, help="Output RTP port number")
    parser.add_argument("sdp_file", type=int, help="File to place sdp information into")
    parser.add_argument(
        "--extra_args", nargs="*", default=[], help="Extra FFmpeg arguments (key=value)"
    )

    args = parser.parse_args()
    extra_args = dict(arg.split("=") for arg in args.extra_args)
    start_ffmpeg(args.input_port, args.output_port, **extra_args)

import argparse
import os
import re
import subprocess as sp
import sys
import time


def start_scrcpy(
    video_port,
    audio_port,
    data_port,
    server_apk_path,
    scrcpy_version,
    tunnel_forward,
    audio,
    control,
    cleanup,
    raw_stream,
    video_bit_rate,
    video_codec_options,
    max_fps,
):

    print(f"Starting scrcpy on device with:")
    print(f"Video port: {video_port}")
    print(f"Audio port: {audio_port}")
    print(f"Data port: {data_port}")

    scrcpy_path_on_device = "/data/local/tmp/scrcpy-server.jar"
    result = sp.run(["adb", "push", server_apk_path, scrcpy_path_on_device])
    if result.returncode == 0:
        print("Pushed scrcpy server to device")
    else:
        print("Failed to push scrcpy server to device", file=sys.stderr)
        return 1

    result = sp.run(["adb", "forward", f"tcp:{video_port}", "localabstract:scrcpy"])
    if result.returncode == 0:
        print("Forwarded port")
    else:
        print("Failed to forward port", file=sys.stderr)
        return 1

    server_cmd = [
        "CLASSPATH=/data/local/tmp/scrcpy-server.jar",
        "app_process / com.genymobile.scrcpy.Server",
        scrcpy_version,
        f"tunnel_forward={tunnel_forward}",
        f"audio={audio}",
        f"control={control}",
        f"cleanup={cleanup}",
        f"raw_stream={raw_stream}",
        f"video_bit_rate={video_bit_rate}",
        f"video_codec_options={video_codec_options}",
        f"max_fps={max_fps}",
    ]
    server_cmd = " ".join(server_cmd)

    result = sp.Popen(["adb", "shell", server_cmd])
    print("Started launching scrcpy")

    start_time = time.time()
    timeout = 20

    while time.time() - start_time < timeout:
        time.sleep(0.5)
        if re.match(r"^\[server", str(result.stdout)):
            print("scrcpy started successfully")
            return 0

    print("Timeout waiting for scrcpy to start", file=sys.stderr)


if __name__ == "__main__":
    scrcpy_server_path_env = os.getenv("SCRCPY_SERVER_PATH")

    parser = argparse.ArgumentParser(
        description="Start scrcpy with specified parameters."
    )
    parser.add_argument(
        "scrcpy_server_path",
        help="Path to scrcpy server",
        default=os.getenv("SCRCPY_SERVER_PATH"),
    )
    parser.add_argument(
        "scrcpy_version",
        help="Version of scrcpy server",
        default=os.getenv("SCRCPY_SERVER_VERSION"),
    )
    parser.add_argument("video_port", help="Video port", default=5000)
    parser.add_argument("audio_port", help="Audio port", default=5001)
    parser.add_argument("data_port", help="Data port", default=5002)
    parser.add_argument("tunnel_forward", help="Tunnel forward option", default=True)
    parser.add_argument("audio", help="Audio option", default=True)
    parser.add_argument("control", help="Control option", default=True)
    parser.add_argument("cleanup", help="Cleanup option", default=True)
    parser.add_argument("raw_stream", help="Raw stream option", default=True)
    parser.add_argument("video_bit_rate", help="Video bit rate option", default=None)
    parser.add_argument("video_codec_options", help="Video codec options", default=None)
    parser.add_argument("max_fps", help="Maximum FPS option", default=None)

    args = parser.parse_args()

    result = start_scrcpy(
        args.video_port,
        args.audio_port,
        args.data_port,
        args.scrcpy_server_path,
        args.scrcpy_version,
        args.tunnel_forward,
        args.audio,
        args.control,
        args.cleanup,
        args.raw_stream,
        args.video_bit_rate,
        args.video_codec_options,
        args.max_fps,
    )
    exit(result)

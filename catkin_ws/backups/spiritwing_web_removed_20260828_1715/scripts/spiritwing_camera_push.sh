#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  spiritwing_camera_push.sh <sn> <source> [front|rear|payload]

Examples:
  # USB/UVC camera
  spiritwing_camera_push.sh SPIRITWING_LUKONG_SN /dev/video0 front

  # Re-stream an existing RTSP source from the UAV
  spiritwing_camera_push.sh SPIRITWING_LUKONG_SN rtsp://127.0.0.1:8554/camera front

  # Jetson/NVIDIA Argus camera
  spiritwing_camera_push.sh SPIRITWING_LUKONG_SN argus:0 front

Environment:
  RTSP_SERVER=rtsp://192.168.50.165:8554
  VIDEO_SIZE=1280x720
  FRAMERATE=25
  BITRATE=2500k
  COPY_STREAM=0        # set 1 for RTSP/H264 source copy
  RTSP_TRANSPORT=tcp   # tcp or udp for RTSP input/output
EOF
}

if [[ $# -lt 2 || $# -gt 3 ]]; then
  usage >&2
  exit 1
fi

SN="$1"
SOURCE="$2"
LABEL="${3:-front}"

RTSP_SERVER="${RTSP_SERVER:-rtsp://192.168.50.165:8554}"
VIDEO_SIZE="${VIDEO_SIZE:-1280x720}"
FRAMERATE="${FRAMERATE:-25}"
BITRATE="${BITRATE:-2500k}"
COPY_STREAM="${COPY_STREAM:-0}"
RTSP_TRANSPORT="${RTSP_TRANSPORT:-tcp}"
OUT_URL="${RTSP_SERVER%/}/${SN}/${LABEL}"

echo "[spiritwing_camera_push] source=${SOURCE}"
echo "[spiritwing_camera_push] output=${OUT_URL}"
echo "[spiritwing_camera_push] size=${VIDEO_SIZE} fps=${FRAMERATE} bitrate=${BITRATE}"
echo "[spiritwing_camera_push] rtsp_transport=${RTSP_TRANSPORT} copy_stream=${COPY_STREAM}"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "[spiritwing_camera_push] ffmpeg not found. Install it: sudo apt install -y ffmpeg" >&2
  exit 2
fi

if [[ "${SOURCE}" == argus:* ]]; then
  SENSOR_ID="${SOURCE#argus:}"
  if ! command -v gst-launch-1.0 >/dev/null 2>&1; then
    echo "[spiritwing_camera_push] gst-launch-1.0 not found. Install gstreamer tools first." >&2
    exit 2
  fi
  WIDTH="${VIDEO_SIZE%x*}"
  HEIGHT="${VIDEO_SIZE#*x}"
  if gst-inspect-1.0 rtspclientsink >/dev/null 2>&1; then
    exec gst-launch-1.0 -e \
      nvarguscamerasrc sensor-id="${SENSOR_ID}" ! \
      "video/x-raw(memory:NVMM),width=${WIDTH},height=${HEIGHT},framerate=${FRAMERATE}/1" ! \
      nvvidconv ! "video/x-raw,format=I420" ! \
      x264enc tune=zerolatency speed-preset=ultrafast bitrate="${BITRATE%k}" key-int-max="${FRAMERATE}" ! \
      h264parse ! rtspclientsink location="${OUT_URL}" protocols=tcp
  fi
  exec gst-launch-1.0 -e \
    nvarguscamerasrc sensor-id="${SENSOR_ID}" ! \
    "video/x-raw(memory:NVMM),width=${WIDTH},height=${HEIGHT},framerate=${FRAMERATE}/1" ! \
    nvvidconv ! "video/x-raw,format=I420" ! \
    x264enc tune=zerolatency speed-preset=ultrafast bitrate="${BITRATE%k}" key-int-max="${FRAMERATE}" ! \
    h264parse config-interval=1 ! \
    fdsink fd=1 | \
    ffmpeg -hide_banner -loglevel info -f h264 -i pipe:0 \
      -c:v copy -an -f rtsp -rtsp_transport "${RTSP_TRANSPORT}" -muxdelay 0.1 "${OUT_URL}"
fi

if [[ "${SOURCE}" == /dev/video* ]]; then
  exec ffmpeg -hide_banner -loglevel info \
    -f v4l2 -framerate "${FRAMERATE}" -video_size "${VIDEO_SIZE}" -i "${SOURCE}" \
    -an -c:v libx264 -preset ultrafast -tune zerolatency \
    -pix_fmt yuv420p -b:v "${BITRATE}" -g "${FRAMERATE}" \
    -f rtsp -rtsp_transport "${RTSP_TRANSPORT}" -muxdelay 0.1 "${OUT_URL}"
fi

if [[ "${SOURCE}" == rtsp://* || "${SOURCE}" == rtmp://* || "${SOURCE}" == http://* || "${SOURCE}" == https://* ]]; then
  if [[ "${COPY_STREAM}" == "1" ]]; then
    exec ffmpeg -hide_banner -loglevel info \
      -rtsp_transport "${RTSP_TRANSPORT}" -i "${SOURCE}" \
      -an -c:v copy \
      -f rtsp -rtsp_transport "${RTSP_TRANSPORT}" -muxdelay 0.1 "${OUT_URL}"
  fi
  exec ffmpeg -hide_banner -loglevel info \
    -rtsp_transport "${RTSP_TRANSPORT}" -i "${SOURCE}" \
    -an -c:v libx264 -preset ultrafast -tune zerolatency \
    -pix_fmt yuv420p -b:v "${BITRATE}" -g "${FRAMERATE}" \
    -f rtsp -rtsp_transport "${RTSP_TRANSPORT}" -muxdelay 0.1 "${OUT_URL}"
fi

exec ffmpeg -hide_banner -loglevel info \
  -i "${SOURCE}" \
  -an -c:v libx264 -preset ultrafast -tune zerolatency \
  -pix_fmt yuv420p -b:v "${BITRATE}" -g "${FRAMERATE}" \
  -f rtsp -rtsp_transport "${RTSP_TRANSPORT}" -muxdelay 0.1 "${OUT_URL}"

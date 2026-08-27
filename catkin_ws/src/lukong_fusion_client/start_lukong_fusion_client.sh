#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== 启动路空 ROS1 地图融合客户端 ==="

if ! command -v python3 >/dev/null 2>&1; then
  echo "错误: 未找到 python3"
  exit 1
fi

python3 -c "import flask, requests, numpy" >/dev/null 2>&1 || {
  echo "缺少 Python 依赖，开始安装 flask requests numpy ..."
  pip3 install flask requests numpy
}

if [ -z "${ROS_DISTRO:-}" ]; then
  if [ -f /opt/ros/noetic/setup.bash ]; then
    source /opt/ros/noetic/setup.bash
  else
    echo "错误: ROS1 Noetic 环境未设置"
    echo "请先执行: source /opt/ros/noetic/setup.bash"
    exit 1
  fi
fi

if ! rospack find lukong_fusion_client >/dev/null 2>&1; then
  echo "当前 shell 还没有 source 包所在 catkin 工作空间。"
  echo "请先在工作空间执行: source devel/setup.bash"
  echo "当前脚本目录: $SCRIPT_DIR"
  exit 1
fi

roslaunch lukong_fusion_client lukong_fusion_client.launch

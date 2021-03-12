# jetson-pose-container
Docker container to run a pose estimation DL model

## Quick Start

Run the following commands.

```
git clone https://github.com/tokk-nv/jetson-pose-container
cd jetson-pose-container
./scripts/set_nvidia_runtime.sh
./scripts/copy-jetson-ota-key.sh
./build.sh
./run.sh --container jetson-pose:r32.5.0
```

## Dependencies

> PLANNED
This container has `trt_pose` installed and use it's pose estimation network.

[`trt_pose`](https://github.com/NVIDIA-AI-IOT/trt_pose)

## Input

> PLANNED
- CSI camera (IMX219)

## Output

> PLANNED
- ZMQ message (json format to be defined) publishing all the keypoints

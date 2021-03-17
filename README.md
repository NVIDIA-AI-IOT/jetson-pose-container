# jetson-pose-container
Docker container to run a pose estimation DL model

## Quick Start

Run the following commands.

```
git clone https://github.com/tokk-nv/jetson-pose-container
cd jetson-pose-container
./scripts/set_nvidia_runtime.sh
./scripts/copy-jetson-ota-key.sh
sudo ./run.sh
```

It should pull the container image from Docker Hub and once that is done it should launch into the terminal within the container.

Jupyter Lab should be running, so you can access using a browser on any device on the same network at `<IP address>:8888`.

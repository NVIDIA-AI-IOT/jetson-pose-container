#!/usr/bin/env bash
#
# This script builds the jetson-inference docker container from source.
# It should be run from the root dir of the jetson-inference project:
#
#     $ cd /path/to/your/jetson-pose-container
#     $ ./build.sh
#
# Also you should set your docker default-runtime to nvidia:
#     $ ./scripts/set_nvidia_runtime.sh
#

BASE_IMAGE=$1

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"


DOCKER_REPO="jetson-pose"
POSE_VERSION="trt_pose-0.0.1"
TAG="$POSE_VERSION-amd64"

echo "BASE_IMAGE=$BASE_IMAGE"
echo "TAG=$TAG"


# sanitize workspace (so extra files aren't added to the container)


# build the container
echo "sudo docker build -t $DOCKER_REPO:$TAG -f ${SCRIPTPATH}/Dockerfile.amd64 \
          --build-arg BASE_IMAGE=$BASE_IMAGE \
          .
"
sudo docker build -t $DOCKER_REPO:$TAG -f ${SCRIPTPATH}/Dockerfile.amd64 \
          --build-arg BASE_IMAGE=$BASE_IMAGE \
	  .

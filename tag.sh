#!/usr/bin/env bash

# Copyright (c) 2020-2021, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# find L4T_VERSION
source $SCRIPTPATH/tools/l4t-version.sh

# local container:tag name
CONTAINER_IMAGE="jetson-pose:r$L4T_VERSION"

# incompatible L4T version
function version_error()
{
	echo "cannot find compatible jetson-inference docker container for L4T R$L4T_VERSION"
	echo "please upgrade to the latest JetPack, or build jetson-inference natively from source"
	exit 1
}

# get remote container URL
if [ $L4T_RELEASE -eq 32 ]; then
	if [ $L4T_REVISION_MAJOR -eq 4 ]; then
	     if [ $L4T_REVISION_MINOR -gt 4 ]; then
			CONTAINER_REMOTE_IMAGE="cyato/$CONTAINER_IMAGE" #"nvcr.io/ea-linux4tegra/$CONTAINER_IMAGE"
		elif [ $L4T_REVISION_MINOR -ge 3 ]; then
			CONTAINER_REMOTE_IMAGE="cyato/$CONTAINER_IMAGE"
		else
			version_error
		fi
	elif [ $L4T_REVISION_MAJOR -eq 5 ]; then
		if [ $L4T_REVISION_MINOR -eq 0 ]; then
			CONTAINER_REMOTE_IMAGE="cyato/$CONTAINER_IMAGE"
	    elif [ $L4T_REVISION_MINOR -eq 1 ]; then
			# L4T R32.5.1 runs the R32.5.0 container
			CONTAINER_IMAGE="jetson-pose:r32.5.0"
			CONTAINER_REMOTE_IMAGE="cyato/$CONTAINER_IMAGE"
		else
			CONTAINER_REMOTE_IMAGE="cyato/$CONTAINER_IMAGE" #"nvcr.io/ea-linux4tegra/$CONTAINER_IMAGE"
		fi
	elif [ $L4T_REVISION_MAJOR -gt 5 ]; then
		CONTAINER_REMOTE_IMAGE="cyato/$CONTAINER_IMAGE" #"nvcr.io/ea-linux4tegra/$CONTAINER_IMAGE"
	else
		version_error
	fi
else
	version_error
fi
	
# check for local image
if [[ "$(docker images -q $CONTAINER_IMAGE 2> /dev/null)" == "" ]]; then
	CONTAINER_IMAGE=$CONTAINER_REMOTE_IMAGE
fi


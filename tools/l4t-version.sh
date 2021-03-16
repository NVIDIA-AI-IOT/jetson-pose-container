#!/bin/bash

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

L4T_VERSION_STRING=$(head -n 1 /etc/nv_tegra_release)

if [ -z "$L4T_VERSION_STRING" ]; then
	echo "reading L4T version from \"dpkg-query --show nvidia-l4t-core\""

	L4T_VERSION_STRING=$(dpkg-query --showformat='${Version}' --show nvidia-l4t-core)
	L4T_VERSION_ARRAY=(${L4T_VERSION_STRING//./ })	

	#echo ${L4T_VERSION_ARRAY[@]}
	#echo ${#L4T_VERSION_ARRAY[@]}

	L4T_RELEASE=${L4T_VERSION_ARRAY[0]}
	L4T_REVISION=${L4T_VERSION_ARRAY[1]}
else
	echo "reading L4T version from /etc/nv_tegra_release"

	L4T_RELEASE=$(echo $L4T_VERSION_STRING | cut -f 2 -d ' ' | grep -Po '(?<=R)[^;]+')
	L4T_REVISION=$(echo $L4T_VERSION_STRING | cut -f 2 -d ',' | grep -Po '(?<=REVISION: )[^;]+')
fi

L4T_REVISION_MAJOR=${L4T_REVISION:0:1}
L4T_REVISION_MINOR=${L4T_REVISION:2:1}

L4T_VERSION="$L4T_RELEASE.$L4T_REVISION"

echo "L4T BSP Version:  L4T R$L4T_VERSION"

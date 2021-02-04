# Copyright (c) 2020, NVIDIA CORPORATION. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
#
# Build this Dockerfile by running the following commands:
#
#     $ cd /path/to/your/jetson-pose-container
#     $ ./build.sh
#
# Also you should set your docker default-runtime to nvidia:
#     $ ./script/set_nvidia_runtime.sh
#

ARG BASE_IMAGE=nvcr.io/nvidia/l4t-pytorch:r32.4.4-pth1.6-py3
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL /bin/bash

WORKDIR /pose_workdir

ENV JUPYTER_WORKDIR=/pose_workdir
ARG JUPYTER_PASSWORD=jetson
ENV JUPYTER_PASSWORD=${JUPYTER_PASSWORD}

#
# install pre-requisite packages
#
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
            cmake \
            curl \
    && rm -rf /var/lib/apt/lists/*

# pip dependencies for pytorch-ssd
RUN pip3 install --verbose --upgrade Cython && \
    pip3 install --verbose boto3 pandas

# pip dependencies for trt_pose
RUN pip3 install tqdm cython pycocotools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
            python3-matplotlib \
    && rm -rf /var/lib/apt/lists/*


# install jetcam (lock to latest commit as of Sept 2020)
#
RUN git clone https://github.com/NVIDIA-AI-IOT/jetcam.git && \
    cd jetcam && \
    git checkout 508ff3a && \
    python3 setup.py install && \
    cd ../ && \
    rm -rf jetcam
    
#
# install OpenCV (with GStreamer support)
#
COPY jetson-ota-public.asc /etc/apt/trusted.gpg.d/jetson-ota-public.asc

RUN echo "deb https://repo.download.nvidia.com/jetson/common r32.4 main" > /etc/apt/sources.list.d/nvidia-l4t-apt-source.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
            libopencv-python \
		  curl \
    && rm /etc/apt/sources.list.d/nvidia-l4t-apt-source.list \
    && rm -rf /var/lib/apt/lists/*

    
#
# install JupyterLab (lock to 2.2.6, latest as of Sept 2020)
#
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
            nodejs \
            libffi-dev \
		  libssl1.0-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install jupyter jupyterlab==2.2.6 --verbose && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter lab --generate-config && \
    python3 -c "from notebook.auth.security import set_password; set_password('${JUPYTER_PASSWORD}', '/root/.jupyter/jupyter_notebook_config.json')"

#
# install jupyter_clickable_widget
# 
# note that the 'python3 setup.py build' step is expected to fail:
#   https://github.com/jaybdub/jupyter_clickable_image_widget/issues/1
#
RUN cd /opt && \
    git clone https://github.com/jaybdub/jupyter_clickable_image_widget && \
    cd jupyter_clickable_image_widget && \
    git checkout tags/v0.1 && \
    pip3 install -e . && \
    jupyter labextension install js && \
    jupyter lab build


#
# install version of traitlets with dlink.link() feature
# (added after 4.3.3 and commits after the one below only support Python 3.7+) 
#
RUN python3 -m pip install git+https://github.com/ipython/traitlets@dead2b8cdde5913572254cf6dc70b5a6065b86f8


# =================
# INSTALL torch2trt
# =================
ENV TORCH2TRT_REPO_DIR=$JUPYTER_WORKDIR
RUN cd ${TORCH2TRT_REPO_DIR} && \
    git clone https://github.com/NVIDIA-AI-IOT/torch2trt && \
    cd torch2trt && \
    python3 setup.py install --plugins

# ========================================
# Install other misc packages for trt_pose
# ========================================
RUN pip3 install tqdm cython pycocotools && \
    apt-get install python3-matplotlib
RUN pip3 install traitlets
RUN pip3 install -U scikit-learn

# ================
# INSTALL trt_pose
# ================
ENV TRTPOSE_REPO_DIR=$JUPYTER_WORKDIR
RUN cd ${TRTPOSE_REPO_DIR} && \
    git clone https://github.com/NVIDIA-AI-IOT/trt_pose && \
    cd trt_pose && \
    git checkout a89b422e0d72c4d537d7d4f39d03589f7ac236c0 && \
    python3 setup.py install


# ================
# Pre-cache models 
# ================
RUN python3 -c "import torchvision; \
                model = torchvision.models.resnet18(pretrained=True); \
                model = torchvision.models.resnet34(pretrained=True); \
                model = torchvision.models.resnet50(pretrained=True); \
                model = torchvision.models.resnet101(pretrained=True); \
                model = torchvision.models.resnet152(pretrained=True) "

# Jupyter listens on 8888.
EXPOSE 8888

#
# set jupyter auto-start command
#
CMD /bin/bash -c "cd $JUPYTER_WORKDIR && jupyter lab --ip 0.0.0.0 --port 8888 --allow-root &> /var/log/jupyter.log" & \
	echo "allow 10 sec for JupyterLab to start @ http://$(hostname -I | cut -d' ' -f1):8888 (password ${JUPYTER_PASSWORD})" && \
	echo "JupterLab logging location:  /var/log/jupyter.log  (inside the container)" && \
	/bin/bash

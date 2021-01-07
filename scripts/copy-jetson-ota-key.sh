#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

cp /etc/apt/trusted.gpg.d/jetson-ota-public.asc $SCRIPTPATH/../

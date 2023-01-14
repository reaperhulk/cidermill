#!/bin/bash
set -xe
# TODO: doesn't support org level right now

TOKEN=$1
NAME=$2
URL=$3

if [[ -n "$4" ]]; then
    LABELS="--labels ${4}"
fi

tar zxf actions-runner.tar.gz

sudo scutil --set HostName $NAME
sudo scutil --set ComputerName $NAME

cd actions-runner
./config.sh --url $URL --unattended --token $TOKEN --name $NAME --ephemeral $LABELS
./run.sh
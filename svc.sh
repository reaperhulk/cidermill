#!/bin/bash
#
# This script is derived from the actions/runner templates provided by GitHub
# under the MIT license (reproduced below).
# The MIT License (MIT)
# Copyright (c) 2019 GitHub
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

SVC_NAME="cidermill"

SVC_CMD=$1
RUNNER_ROOT=$(pwd)

LAUNCH_PATH="${HOME}/Library/LaunchAgents"
PLIST_PATH="${LAUNCH_PATH}/${SVC_NAME}.plist"
TEMPLATE_PATH="./files/launchd.template"
TEMP_PATH=./files/launchd.plist.temp

function failed()
{
   local error=${1:-Undefined error}
   echo "Failed: $error" >&2
   exit 1
}

if [ ! -f "${TEMPLATE_PATH}" ]; then
    failed "Can't find the template. You must run from cidermill root for this script to work."
fi

function install()
{
    echo "Creating launchd plist in ${PLIST_PATH}"

    if [ ! -d  "${LAUNCH_PATH}" ]; then
        mkdir "${LAUNCH_PATH}"
    fi

    if [ -f "${PLIST_PATH}" ]; then
        failed "error: exists ${PLIST_PATH}"
    fi

    if [ -f "${TEMP_PATH}" ]; then
      rm "${TEMP_PATH}" || failed "failed to delete ${TEMP_PATH}"
    fi

    log_path="${HOME}/Library/Logs/${SVC_NAME}"
    echo "Creating ${log_path}"
    mkdir -p "${log_path}" || failed "failed to create ${log_path}"

    echo "Creating ${PLIST_PATH}"
    sed "s/{{User}}/${USER}/g; s/{{SvcName}}/$SVC_NAME/g; s@{{RunnerRoot}}@${RUNNER_ROOT}@g; s@{{UserHome}}@$HOME@g;" "${TEMPLATE_PATH}" > "${TEMP_PATH}" || failed "failed to create replacement temp file"
    mv "${TEMP_PATH}" "${PLIST_PATH}" || failed "failed to copy plist"

    echo "install complete"
}

function start()
{
    echo "starting ${SVC_NAME}"
    launchctl load -w "${PLIST_PATH}" || failed "failed to load ${PLIST_PATH}"
    status
}

function stop()
{
    echo "stopping ${SVC_NAME}"
    launchctl unload "${PLIST_PATH}" || failed "failed to unload ${PLIST_PATH}"
    status
}

function uninstall()
{
    echo "uninstalling ${SVC_NAME}"
    stop
    rm "${PLIST_PATH}" || failed "failed to delete ${PLIST_PATH}"
}

function status()
{
    echo "status ${SVC_NAME}:"
    if [ -f "${PLIST_PATH}" ]; then
        echo
        echo "${PLIST_PATH}"
    else
        echo
        echo "not installed"
        echo
        return
    fi

    echo
    status_out=$(launchctl list | grep "${SVC_NAME}")
    if [ -n "$status_out" ]; then
        echo Started:
        echo "$status_out"
        echo
    else
        echo Stopped
        echo
    fi
}

function tail()
{
    echo "Run this: tail -f \"${HOME}/Library/Logs/${SVC_NAME}/stdout.log\" \"${HOME}/Library/Logs/${SVC_NAME}/stderr.log\""
}

function usage()
{
    echo
    echo "Usage (do not use sudo!):"
    echo "./svc.sh [install, start, stop, status, tail, uninstall]"
    echo
}

case $SVC_CMD in
   "install") install;;
   "status") status;;
   "uninstall") uninstall;;
   "start") start;;
   "stop") stop;;
   "tail") tail;;
   *) usage;;
esac

exit 0

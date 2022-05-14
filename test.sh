#!/bin/bash
set -e
set -o pipefail
if [ -n "$DEBUG" ]; then
    set -x
fi

if [ -z "$CONTAINERED" ]; then
    exec docker run \
        -e DEBUG="$DEBUG" \
        -e CONTAINERED=1 \
        -v "$PWD":/app \
        -w /app \
        -i node:18-alpine \
        sh ./test.sh
fi

uid="$(id -u)"
if [ "$uid" == "0" ]; then
    chown 1000 /etc/resolv.conf
    npm -g i pnpm
    exec su node -c 'sh ./test.sh'
fi

switch_offline() {
    echo >/etc/resolv.conf
}

switch_online() {
    echo "nameserver 8.8.8.8" >/etc/resolv.conf
}

export YARN_ENABLE_GLOBAL_CACHE=true
export YARN_ENABLE_TELEMETRY=false

{
    cd "$(mktemp -d)"
    npm init -y >/dev/null
    pnpm add lodash@4.17.21

    switch_offline
    {
        cd "$(mktemp -d)"
        npm init -y >/dev/null
        pnpm add lodash@4.17.21
        echo '>>>'
        echo '>>> OK: offline pnpm install test'
        echo '>>>'
    }
    switch_online
}

{
    cd "$(mktemp -d)"
    npm init -y >/dev/null
    yarn set version berry --verbose
    yarn add lodash@4.17.21

    switch_offline
    {
        cd "$(mktemp -d)"
        npm init -y >/dev/null

        yarn set version berry --verbose || {
            echo '>>>'
            echo '>>> FAILED: offline yarn berry bootstrap test'
            echo '>>>'

            switch_online
            yarn set version berry --verbose
            switch_offline
        }

        yarn add lodash@4.17.21 || {
            echo '>>>'
            echo '>>> FAILED: offline yarn install test'
            echo '>>>'
        }
    }
    switch_online
}

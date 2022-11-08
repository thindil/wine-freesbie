#!/bin/sh

TARGET="$(realpath "$0")"

if [ -z "$WINESERVER" ] && [ -f "${TARGET}server32" ]
then
  export WINESERVER="${TARGET}server32"
fi

export GST_PLUGIN_SYSTEM_PATH_1_0="${TARGET%/*/*/*}/lib/gstreamer-1.0"

# Workaround for https://bugs.winehq.org/show_bug.cgi?id=50257
export LD_BIND_NOW=1
export LD_32_BIND_NOW=1

exec "${TARGET}.bin" "$@"

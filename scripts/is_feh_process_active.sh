#!/bin/bash
# returns 0 if a feh process with given name $1 is active, else 1
# grep -v "grep" exludes this script from being matched in the running process
# TODO: Tight dependency on feh with this script
feh_process_with_diagram_exists=$(ps aux | grep "feh" | grep "auto-reload" | grep -v "grep" | grep "$1" -m 1)

if [ -n "$feh_process_with_diagram_exists" ]; then
  exit 0
else
  exit 1
fi


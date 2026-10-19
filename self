#!/bin/sh
# Runs OpenSelf from the submodule next to this script: ./self serve, ./self push, ./self pull ...
here=$(cd "$(dirname "$0")" && pwd)
if [ ! -f "$here/openself/openself/__init__.py" ]; then
  git -C "$here" submodule update --init --quiet || exit 1
fi
cd "$here" && PYTHONPATH="$here/openself" exec python3 -m openself "$@"

#!/usr/bin/env bash
set -euo pipefail

cd repo

if [[ ! -f Packages ]]; then
  echo "No existe Packages; ¿has ejecutado build-apt-repo.sh?"; exit 1
fi

awk '/^Filename: /{print $2}' Packages > /tmp/files.txt

ERROR=0
while IFS= read -r f; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: falta $f"
    ERROR=1
  fi
done < /tmp/files.txt

NUM_PKGS=$(grep -c '^Package: ' Packages || true)
echo "Packages contiene $NUM_PKGS entradas."

if [[ "$ERROR" -ne 0 ]]; then
  exit 1
fi

#!/usr/bin/env bash
set -Eeuo pipefail

API_URL="https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest"

if [[ -z "${GH_TOKEN:-}" ]]; then
    echo "Falta GH_TOKEN"
    exit 1
fi

mkdir -p repo

echo "Obteniendo metadatos de la última release..."

curl \
  --fail \
  --show-error \
  --location \
  --retry 10 \
  --retry-all-errors \
  --retry-delay 5 \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "User-Agent: fastfetch-repo-builder" \
  -o /tmp/release.json \
  "$API_URL"

LAST_VERSION=$(jq -r '.tag_name' /tmp/release.json)

[[ -n "$LAST_VERSION" && "$LAST_VERSION" != "null" ]] || exit 1

echo "Versión detectada: $LAST_VERSION"
echo "LAST_VERSION=$LAST_VERSION" >> "$GITHUB_ENV"

mkdir -p "repo/v${LAST_VERSION}"

if [[ -n "${APT_ARCH_FILTER:-}" ]]; then
    jq -r --arg re "$APT_ARCH_FILTER" '.assets[] | select(.name|endswith(".deb")) | select(.name|test($re)) | "\(.id)|\(.name)"' /tmp/release.json > /tmp/assets.txt
else
    jq -r '.assets[] | select(.name|endswith(".deb")) | "\(.id)|\(.name)"' /tmp/release.json > /tmp/assets.txt
fi

SUCCESS=0

while IFS="|" read -r asset_id asset_name; do
    [[ -n "$asset_id" ]] || continue

    output="repo/$asset_name"

    if curl \
        --fail \
        --show-error \
        --location \
        --retry 10 \
        --retry-all-errors \
        --retry-delay 5 \
        --connect-timeout 30 \
        --max-time 1800 \
        -H "Authorization: Bearer $GH_TOKEN" \
        -H "Accept: application/octet-stream" \
        "https://api.github.com/repos/fastfetch-cli/fastfetch/releases/assets/$asset_id" \
        -o "$output"
    then
        if dpkg-deb --info "$output" >/dev/null 2>&1; then
            SUCCESS=1
        else
            rm -f "$output"
        fi
    fi
done < /tmp/assets.txt

[[ "$SUCCESS" -eq 1 ]] || { echo "No se descargó ningún paquete válido"; exit 1; }

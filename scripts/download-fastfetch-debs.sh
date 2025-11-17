#!/usr/bin/env bash
set -euo pipefail

# Descarga JSON de la última release de fastfetch-cli
API_URL="https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest"

if [[ -z "${GH_TOKEN:-}" ]]; then
  echo "Falta GH_TOKEN en el entorno"; exit 1
fi

mkdir -p repo

echo "Obteniendo metadatos de la última release desde GitHub API..."
curl --fail --show-error --location --retry 3 --retry-delay 2 \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "User-Agent: gh-actions-fastfetch" \
  -o /tmp/release.json "$API_URL"

LAST_VERSION=$(jq -r '.tag_name' /tmp/release.json)
if [[ -z "$LAST_VERSION" || "$LAST_VERSION" == "null" ]]; then
  echo "No se pudo obtener el tag de la última release"; exit 1
fi

echo "Última versión detectada: $LAST_VERSION"
echo "LAST_VERSION=$LAST_VERSION" >> "$GITHUB_ENV"

mkdir -p "repo/v${LAST_VERSION}"
rm -f repo/*.deb || true

# Extrae URLs de assets .deb, con filtro opcional por arquitectura
if [[ -n "${APT_ARCH_FILTER:-}" ]]; then
  echo "Usando filtro de arquitecturas: '${APT_ARCH_FILTER}'"
  jq -r --arg re "$APT_ARCH_FILTER" \
    '.assets[] | select(.browser_download_url | endswith(".deb")) | select(.name | test($re)) | .browser_download_url' \
    /tmp/release.json > /tmp/deb_urls.txt
else
  jq -r '.assets[].browser_download_url | select(endswith(".deb"))' \
    /tmp/release.json > /tmp/deb_urls.txt
fi

if [[ ! -s /tmp/deb_urls.txt ]]; then
  echo "No hay assets .deb en la release $LAST_VERSION (filtro: '${APT_ARCH_FILTER:-}')"
  exit 1
fi

echo "Descargando paquetes .deb:"
while IFS= read -r url; do
  file="repo/$(basename "$url")"
  echo "  - $(basename "$url")"
  curl --fail --show-error --location --retry 3 --retry-delay 2 \
    -o "$file" "$url"
done < /tmp/deb_urls.txt

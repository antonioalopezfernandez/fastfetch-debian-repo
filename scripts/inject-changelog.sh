#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${LAST_VERSION:-}" ]]; then
  echo "LAST_VERSION no está definido en el entorno"; exit 1
fi

shopt -s nullglob

if ! compgen -G "repo/*.deb" > /dev/null; then
  echo "No hay .deb en repo/ para inyectar el changelog"; exit 1
fi

echo "Inyectando changelog en los .deb para la versión ${LAST_VERSION}..."

# Descarga el CHANGELOG.md:
# 1) tag concreto
# 2) main
# 3) master
if ! curl -fsSL \
  "https://raw.githubusercontent.com/fastfetch-cli/fastfetch/${LAST_VERSION}/CHANGELOG.md" \
  -o /tmp/CHANGELOG.md; then
  if ! curl -fsSL \
    "https://raw.githubusercontent.com/fastfetch-cli/fastfetch/main/CHANGELOG.md" \
    -o /tmp/CHANGELOG.md; then
    curl -fsSL \
      "https://raw.githubusercontent.com/fastfetch-cli/fastfetch/master/CHANGELOG.md" \
      -o /tmp/CHANGELOG.md
  fi
fi

# Extrae solo la sección de la versión actual (si existe)
ver="${LAST_VERSION#v}"
awk -v ver="$ver" '
  BEGIN{printit=0}
  /^[[:space:]]*#{1,6}[[:space:]]/ {
    if (printit) exit
    line=$0
    gsub(/[][]/,"", line)
    if (line ~ ("[[:space:]]v?" ver "([[:space:]]|$|\\))")) { printit=1; print; next }
  }
  { if (printit) print }
' /tmp/CHANGELOG.md > /tmp/CHANGELOG_SECTION.md || true

if [[ ! -s /tmp/CHANGELOG_SECTION.md ]]; then
  echo "Aviso: no se encontró sección específica de $ver; se usará todo el CHANGELOG."
  cp /tmp/CHANGELOG.md /tmp/CHANGELOG_SECTION.md
fi

for deb in repo/*.deb; do
  echo "  - $(basename "$deb")"

  workdir="$(mktemp -d)"
  fakeroot dpkg-deb -R "$deb" "$workdir"

  PKG_NAME=$(awk -F': *' '$1=="Package"{print $2; exit}' "$workdir/DEBIAN/control")

  # Crea el changelog comprimido
  DOCDIR="$workdir/usr/share/doc/$PKG_NAME"
  mkdir -p "$DOCDIR"
  gzip -9c /tmp/CHANGELOG_SECTION.md > "$DOCDIR/changelog.Debian.gz"
  cp "$DOCDIR/changelog.Debian.gz" "$DOCDIR/changelog.gz"
  cp "$DOCDIR/changelog.Debian.gz" "$DOCDIR/NEWS.Debian.gz"

  # Regenera md5sums
  (
    cd "$workdir"
    find . -type f ! -path './DEBIAN/*' -printf '%P\n' \
      | LC_ALL=C sort \
      | xargs -r md5sum > DEBIAN/md5sums
  )

  # Reempaqueta con sufijo inmutable -repo1
  NEW_DEB="${deb}.new"
  fakeroot dpkg-deb -b "$workdir" "$NEW_DEB"

  DEB_VER=$(dpkg-deb -f "$NEW_DEB" Version)
  DEB_ARCH=$(dpkg-deb -f "$NEW_DEB" Architecture)
  FINAL_NAME="${PKG_NAME}_${DEB_VER}-repo1_${DEB_ARCH}.deb"

  mkdir -p "repo/v${LAST_VERSION}"
  mv "$NEW_DEB" "repo/v${LAST_VERSION}/$FINAL_NAME"

  rm -f "$deb"
  rm -rf "$workdir"
done

shopt -u nullglob

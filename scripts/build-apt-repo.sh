#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${LAST_VERSION:-}" ]]; then
  echo "LAST_VERSION no está definido en el entorno"; exit 1
fi
if [[ -z "${GPG_PASSPHRASE:-}" ]]; then
  echo "Falta GPG_PASSPHRASE en el entorno"; exit 1
fi
if [[ -z "${KEY_FP:-}" ]]; then
  echo "Falta KEY_FP en el entorno"; exit 1
fi

cd repo

NUM_PKGS=$(ls -1 "v${LAST_VERSION}"/*.deb 2>/dev/null | wc -l || echo 0)
echo "Generando índices para v${LAST_VERSION} (${NUM_PKGS} paquetes)..."

# Genera Packages y Packages.gz
dpkg-scanpackages -m "v${LAST_VERSION}" /dev/null > Packages
gzip -9f -c Packages > Packages.gz

# apt.conf con metadatos del repo
cat > apt.conf <<EOF
APT::FTPArchive::Release {
  Origin "fastfetch (community mirror)";
  Label "fastfetch";
  Suite "stable";
  Codename "fastfetch";
};
EOF

# Genera Release
apt-ftparchive -c=apt.conf release . > Release

# Firma Release → Release.gpg e InRelease
gpg --batch --yes --pinentry-mode loopback \
    --passphrase "$GPG_PASSPHRASE" \
    -abs -o Release.gpg Release

gpg --batch --yes --pinentry-mode loopback \
    --passphrase "$GPG_PASSPHRASE" \
    --clearsign -o InRelease Release

# Exporta la clave pública (ASCII armor)
gpg --armor --export "$KEY_FP" > public.gpg

# Evita que GitHub Pages toque nada
: > .nojekyll

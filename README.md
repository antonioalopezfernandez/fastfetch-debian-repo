# 🐧 Repositorio APT de Fastfetch (firmado e inmutable)

Este repositorio proporciona **paquetes `.deb` de [Fastfetch](https://github.com/fastfetch-cli/fastfetch)** listos para instalar y actualizar en sistemas basados en Debian o Ubuntu.  
Los paquetes son **firmados con GPG**, contienen su **changelog integrado** y se publican de forma **inmutable** (`-repo1`).

---

## 📦 Instalación del repositorio

Ejecuta estos comandos como **root**:

```bash
# 1. Descargar e importar la clave GPG
curl -fsSL https://antonioalopezfernandez.github.io/fastfetch-debian-repo/public.gpg   | gpg --dearmor -o /usr/share/keyrings/fastfetch.gpg

# 2. Añadir el repositorio APT
echo "deb [signed-by=/usr/share/keyrings/fastfetch.gpg] https://antonioalopezfernandez.github.io/fastfetch-debian-repo ./"   > /etc/apt/sources.list.d/fastfetch-debian-repo.list

# 3. Actualizar índices y comprobar
apt update
```

Si todo va bien, deberías ver algo como:
```
Obtenido:1 https://antonioalopezfernandez.github.io/fastfetch-debian-repo  InRelease [firma OK]
```

---

## 🚀 Instalar o actualizar Fastfetch

Una vez añadido el repositorio:

```bash
apt install fastfetch
```

APT instalará automáticamente la última versión publicada.  
Si ya lo tienes instalado desde otra fuente, se actualizará a la versión del repo (ej. `2.54.0-repo1`).

---

## 🔐 Verificación manual de la firma (opcional)

Puedes comprobar la firma del `InRelease` manualmente:

```bash
curl -fsSLO https://antonioalopezfernandez.github.io/fastfetch-debian-repo/InRelease
gpgv --keyring /usr/share/keyrings/fastfetch.gpg InRelease
```

Si todo está correcto, verás un mensaje tipo:
```
gpgv: Signature made ... using RSA key ...
gpgv: Good signature from "Fastfetch Repo Signing Key"
```

---

## 🧹 Desinstalar el repositorio

Si quieres eliminarlo completamente:

```bash
rm -f /etc/apt/sources.list.d/fastfetch-debian-repo.list
rm -f /usr/share/keyrings/fastfetch.gpg
apt update
```

---

## 📄 Información técnica

- **URL del repo:** [https://antonioalopezfernandez.github.io/fastfetch-debian-repo](https://antonioalopezfernandez.github.io/fastfetch-debian-repo)
- **Estructura:** repositorio plano (`Packages`, `InRelease`, `Release.gpg`)
- **Firmas:** GPG ASCII armor (`public.gpg`)
- **Origen / Label:** `fastfetch (community mirror)`
- **Suite / Codename:** `stable / fastfetch`
- **Frecuencia de actualización:** diaria (02:00 UTC)
- **Automatización:** GitHub Actions (`apt-repo-fastfetch.yml`)

---

## 💬 Notas

- Este repositorio no altera los binarios originales de Fastfetch; solo añade:
  - `changelog.Debian.gz` (extraído del `CHANGELOG.md`)
  - sufijo `-repo1` en el número de versión (para mantener inmutabilidad)
  - firma GPG y metadatos APT estándar

---

### Ejemplo rápido

```bash
apt install -y curl gpg
curl -fsSL https://antonioalopezfernandez.github.io/fastfetch-debian-repo/setup.sh | bash
fastfetch
```

---

🧩 **Mantenido por:** [Antonio López Fernández](https://github.com/antonioalopezfernandez)  
🔑 **Clave pública:** [public.gpg](https://antonioalopezfernandez.github.io/fastfetch-debian-repo/public.gpg)
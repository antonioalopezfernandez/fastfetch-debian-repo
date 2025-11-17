# 🐧 Repositorio APT de Fastfetch (firmado e inmutable)

Este repositorio proporciona **paquetes `.deb` de [Fastfetch](https://github.com/fastfetch-cli/fastfetch)** listos para instalar y actualizar en sistemas basados en Debian o Ubuntu.  
Los paquetes se publican:

- ✅ **Firmados con GPG**
- ✅ Con **`changelog` integrado** (para herramientas como `apt-listchanges`)
- ✅ Como versiones **inmutables** (`-repo1`), de forma que cada build queda fijada.

---

## 📦 Instalación rápida

Ejecuta estos comandos con un usuario con `sudo` (o como root).

```bash
# 1. Descargar e instalar la clave GPG del repositorio
curl -fsSL https://antonioalopezfernandez.github.io/fastfetch-debian-repo/public.gpg | sudo gpg --dearmor -o /usr/share/keyrings/fastfetch.gpg

# 2. Registrar el repositorio APT
echo 'deb [signed-by=/usr/share/keyrings/fastfetch.gpg] https://antonioalopezfernandez.github.io/fastfetch-debian-repo ./' | sudo tee /etc/apt/sources.list.d/fastfetch-debian-repo.list > /dev/null

# 3. Actualizar índices e instalar Fastfetch
sudo apt modernize-sources
sudo apt update
sudo apt install fastfetch
```

Si todo está bien, durante el `apt update` deberías ver algo similar a:

```text
Get:1 https://antonioalopezfernandez.github.io/fastfetch-debian-repo ./ fastfetch InRelease [X kB]
...
Reading package lists... Done
```

---

## 🚀 Instalar o actualizar Fastfetch

Una vez añadido el repositorio:

```bash
sudo apt install fastfetch
```

APT instalará automáticamente la **última versión disponible en este repo**, con un número de versión del estilo:

```text
fastfetch 2.55.1-repo1
```

---

## 🔐 Verificar la firma manualmente (opcional)

Si quieres comprobar la firma del índice APT:

```bash
# Descargar InRelease
curl -fsSLO https://antonioalopezfernandez.github.io/fastfetch-debian-repo/InRelease

# Verificar la firma con la clave instalada
gpgv --keyring /usr/share/keyrings/fastfetch.gpg InRelease
```

Deberías ver algo similar a:

```text
gpgv: Signature made ...
gpgv: Good signature from "Fastfetch APT (antonioalopezfernandez) <...>"
```

---

## 🧹 Desinstalar el repositorio

Para eliminar completamente el repositorio de tu sistema:

```bash
sudo rm -f /etc/apt/sources.list.d/fastfetch-debian-repo.list
sudo rm -f /usr/share/keyrings/fastfetch.gpg
sudo apt update
```

---

## 📄 Detalles técnicos

- **URL del repo:**  
  `https://antonioalopezfernandez.github.io/fastfetch-debian-repo`
- **Distribución / componente APT:**  
  `fastfetch main`
- **Ficheros publicados:**  
  `Packages`, `Packages.gz`, `Release`, `InRelease`, `Release.gpg`, `public.gpg`, `.nojekyll`
- **Metadatos de Release:**
  - `Origin`: `fastfetch (community mirror)`
  - `Label`: `fastfetch`
  - `Suite`: `stable`
  - `Codename`: `fastfetch`
- **Estructura de paquetes:**  
  Los `.deb` se organizan por versión en carpetas `vX.Y.Z/`, pero APT consume un índice plano (`Packages`) en la raíz.
- **Automatización:**  
  Actualización diaria mediante GitHub Actions (`apt-repo-fastfetch.yml`) a las **02:00 UTC**, obteniendo la última release de `fastfetch-cli/fastfetch` y reempaquetándola como `*-repo1`.

---

## 💬 Notas sobre los paquetes

Este repositorio **no modifica los binarios de Fastfetch**. Los cambios respecto a los `.deb` originales son:

- Se añade `usr/share/doc/fastfetch/changelog.Debian.gz` (y enlaces `changelog.gz` y `NEWS.Debian.gz`), extraído del `CHANGELOG.md` del proyecto.
- Se añade el sufijo `-repo1` en la versión para mantener la inmutabilidad por release del repositorio.
- Se generan y publican los índices APT firmados: `Release`, `InRelease` y `Release.gpg`.

---

🧩 **Mantenido por:** [Antonio López Fernández](https://github.com/antonioalopezfernandez)  
🔑 **Clave pública:** [`public.gpg`](https://antonioalopezfernandez.github.io/fastfetch-debian-repo/public.gpg)

#!/usr/bin/env bash
set -euo pipefail

# ===============================
# CONFIG
# ===============================
MC_VERSION="1.21.11"
LOADER_VERSION="0.18.4"
INSTALLER_VERSION="1.1.1"
RAM="4G"
SERVER_PORT="1980"

MC_JAR="fabric-server-mc.${MC_VERSION}-loader.${LOADER_VERSION}-launcher.${INSTALLER_VERSION}.jar"
MC_URL="https://meta.fabricmc.net/v2/versions/loader/${MC_VERSION}/${LOADER_VERSION}/${INSTALLER_VERSION}/server/jar"

KAMI_URL="https://github.com/kami2k1/tunnel/releases/latest/download/kami-tunnel-linux-amd64.tar.gz"
KAMI_ARCHIVE="kami-tunnel-linux-amd64.tar.gz"

# ===============================
# SYSTEM PACKAGES
# ===============================
need_pkg() {
  dpkg -s "$1" &>/dev/null || sudo apt install -y "$1"
}

sudo apt update
need_pkg sudo
need_pkg wget
need_pkg curl
need_pkg openjdk-21-jdk

# ===============================
# KAMI TUNNEL
# ===============================
if [[ ! -f ./k ]]; then
  echo "Installing Kami Tunnel..."
  wget -q "$KAMI_URL"
  tar -xzf "$KAMI_ARCHIVE"
  chmod +x kami-tunnel
  mv kami-tunnel k
  rm -f "$KAMI_ARCHIVE"
else
  echo "Kami Tunnel already installed."
fi

# ===============================
# MINECRAFT FABRIC SERVER
# ===============================
if [[ ! -f "$MC_JAR" ]]; then
  echo "Downloading Fabric server..."
  curl -fL -o "$MC_JAR" "$MC_URL"
else
  echo "Minecraft server already installed."
fi

# --- Accept EULA ---
echo "eula=true" > eula.txt

# --- server.properties ---
if [[ ! -f server.properties ]]; then
  cat > server.properties <<EOF
#Minecraft server properties
online-mode=false
server-port=${SERVER_PORT}
EOF
fi

# Force online-mode=false
if grep -q '^online-mode=' server.properties; then
  sed -i 's/^online-mode=.*/online-mode=false/' server.properties
else
  echo "online-mode=false" >> server.properties
fi

# Force server port
if grep -q '^server-port=' server.properties; then
  sed -i "s/^server-port=.*/server-port=${SERVER_PORT}/" server.properties
else
  echo "server-port=${SERVER_PORT}" >> server.properties
fi

# ===============================
# RUN SERVICES
# ===============================
echo "Starting Minecraft server..."
java -Xmx${RAM} -jar "$MC_JAR" nogui &

echo "Starting Kami Tunnel..."
./k 80

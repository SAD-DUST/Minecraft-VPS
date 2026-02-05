#!/usr/bin/env bash
set -euo pipefail

# ===== Config =====
MC_VERSION="1.21.11"
LOADER_VERSION="0.18.4"
INSTALLER_VERSION="1.1.1"
RAM="4G"
SERVER_PORT="1980"

JAR="fabric-server-mc.${MC_VERSION}-loader.${LOADER_VERSION}-launcher.${INSTALLER_VERSION}.jar"
URL="https://meta.fabricmc.net/v2/versions/loader/${MC_VERSION}/${LOADER_VERSION}/${INSTALLER_VERSION}/server/jar"

# ===== Packages =====
sudo apt update
sudo apt install -y sudo wget curl
sudo apt upgrade -y
sudo apt install -y openjdk-21-jdk

# ===== Download Fabric server jar =====
if [[ ! -f "$JAR" ]]; then
  echo "Downloading Fabric server jar..."
  curl -fL -o "$JAR" "$URL"
else
  echo "Jar already exists: $JAR"
fi

# ===== Accept EULA =====
cat > eula.txt <<'EOF'
eula=true
EOF

# ===== Ensure server.properties exists, then set online-mode=false =====
# Many servers only generate server.properties after first run, so we create a minimal one if missing.
if [[ ! -f server.properties ]]; then
  cat > server.properties <<EOF
#Minecraft server properties
online-mode=false
server-port=${SERVER_PORT}
EOF
fi

# Force online-mode=false (replace if present, append if not)
if grep -qE '^[[:space:]]*online-mode=' server.properties; then
  sed -i 's/^[[:space:]]*online-mode=.*/online-mode=false/' server.properties
else
  echo "online-mode=false" >> server.properties
fi

# Optional: also ensure your chosen port is set (replace if present, append if not)
if grep -qE '^[[:space:]]*server-port=' server.properties; then
  sed -i "s/^[[:space:]]*server-port=.*/server-port=${SERVER_PORT}/" server.properties
else
  echo "server-port=${SERVER_PORT}" >> server.properties
fi

# ===== Run server =====
java -Xmx${RAM} -jar "$JAR" nogui

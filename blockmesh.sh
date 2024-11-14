#!/bin/bash

set -e

echo "Mengupdate Sistem..."
apt update && apt upgrade -y

echo "Menghapus file yang tidak diperlukan..."
rm -rf blockmesh-cli.tar.gz target

if ! command -v docker &> /dev/null; then
    echo "Docker tidak ditemukan. Menginstall Docker..."
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt update
    apt install -y docker-ce
    echo "Docker berhasil diinstal."
else
    echo "Docker sudah terinstal."
fi

echo "Menginstall Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose berhasil diinstal."
else
    echo "Docker Compose sudah terinstal."
fi

echo "Mengunduh dan mengekstrak BlockMesh CLI..."
curl -L https://github.com/block-mesh/block-mesh-monorepo/releases/download/v0.0.376/blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz -o blockmesh-cli.tar.gz

if [ $? -ne 0 ]; then
    echo "Gagal mengunduh BlockMesh CLI. Periksa koneksi internet Anda."
    exit 1
fi

tar -xzf blockmesh-cli.tar.gz

read -p "Masukan Email: " email
read -s -p "Masukan Password: " password
echo

echo "Menjalankan CLI BlockMesh..."
docker run -it --rm \
    --name blockmesh-cli-container \
    -v $(pwd)/target/x86_64-unknown-linux-gnu/release:/app \
    -e EMAIL="$email" \
    -e PASSWORD="$password" \
    --workdir /app \
    ubuntu:22.04 ./blockmesh-cli --email "$email" --password "$password"
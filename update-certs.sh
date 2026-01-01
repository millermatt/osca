#!/bin/sh

set -eu

# The first argument is the path to the CA certificate file or folder which needs to be added to the system
CACERT_PATH=${1?}

# Function to install certificate management tool and update CA certificates
update_ca_certs() {
    INSTALL_CMD="${1?}"
    CERT_FOLDER=${2?}
    UPDATE_CMD=${3?}

    # Switch to HTTP for package manager
    if command -v apt-get >/dev/null; then
        if [ -f "/etc/apt/sources.list" ]; then
            sed -i 's/https:/http:/g' /etc/apt/sources.list
        fi
        if [ -d "/etc/apt/sources.list.d" ] && [ ! -z "$(ls -A /etc/apt/sources.list.d)" ]; then
            sed -i 's/https:/http:/g' /etc/apt/sources.list.d/*
        fi
    elif command -v yum >/dev/null; then
        echo "sslverify=false" >>/etc/yum.conf
        for file in /etc/yum.repos.d/*; do
            sed -i '/^\[.*\]$/a sslverify=false' "$file"
        done
        sed -i 's/https:/http:/g' /etc/yum.repos.d/*
    elif command -v zypper >/dev/null; then
        sed -i 's/https:/http:/g' /etc/zypp/repos.d/*
    elif command -v apk >/dev/null; then
        sed -i 's/https:/http:/g' /etc/apk/repositories
    elif command -v pacman >/dev/null; then
        sed -i 's/https:/http:/g' /etc/pacman.d/mirrorlist
    fi

    # Ensure the certificate management tool and curl are installed
    NEED_INSTALL=0
    CERT_UPDATE_TOOL=$(echo $UPDATE_CMD | awk '{print $1}')
    if command -v $CERT_UPDATE_TOOL &> /dev/null; then
        echo "Cert update tool, $CERT_UPDATE_TOOL, is installed"
        INSTALL_CMD=$(echo $INSTALL_CMD | awk 'NF{NF--};1')
    else
        echo "Cert update tool, $CERT_UPDATE_TOOL, is not installed"
        NEED_INSTALL=1
    fi
    if ! command -v curl >/dev/null; then
        echo "curl is not installed"
        INSTALL_CMD="${INSTALL_CMD} curl"
        NEED_INSTALL=1
    else
        echo "curl is installed"
    fi
    if [ $NEED_INSTALL -eq 1 ]; then
        eval ${INSTALL_CMD}
    fi

    # Create the folder if it doesn't exist
    mkdir -p ${CERT_FOLDER}

    # Copy the CA certificate file or folder to the appropriate location
    if [ -d "${CACERT_PATH}" ]; then
        if [ "$(ls -A ${CACERT_PATH})" ]; then
            cp -r ${CACERT_PATH}/* ${CERT_FOLDER}
        fi
    else
        cp ${CACERT_PATH} ${CERT_FOLDER}
    fi

    # Update the CA certificates
    ${UPDATE_CMD}

    # Verify SSL requests can be made
    if ! curl -s -v https://www.google.com 2>&1 | grep -Ei "SSL certificate (verify ok|verified via OpenSSL)"; then
        echo "SSL verification failed"
        curl -s -v https://www.google.com
        exit 1
    fi
}

# Identify the system
if grep -q "Alpine Linux" /etc/*-release; then
    update_ca_certs "apk add ca-certificates" "/usr/local/share/ca-certificates" "update-ca-certificates"
elif grep -q "Amazon Linux" /etc/*-release; then
    update_ca_certs "yum install ca-certificates" "/etc/pki/ca-trust/source/anchors/" "update-ca-trust extract"
elif grep -q "Arch Linux" /etc/*-release; then
    update_ca_certs "pacman -Sy ca-certificates-utils" "/etc/ca-certificates/trust-source/anchors/" "trust extract-compat"
elif grep -q "CentOS" /etc/*-release; then
    update_ca_certs "yum install ca-certificates" "/etc/pki/ca-trust/source/anchors/" "update-ca-trust extract"
elif grep -q "Debian" /etc/*-release; then
    update_ca_certs "apt-get update && apt-get install -y ca-certificates" "/usr/local/share/ca-certificates/" "update-ca-certificates"
elif grep -q "Fedora" /etc/*-release; then
    update_ca_certs "dnf install ca-certificates" "/etc/pki/ca-trust/source/anchors/" "update-ca-trust extract"
elif grep -q "Red Hat" /etc/*-release; then
    update_ca_certs "yum install ca-certificates" "/etc/pki/ca-trust/source/anchors/" "update-ca-trust extract"
elif grep -q "SUSE" /etc/*-release; then
    update_ca_certs "zypper install ca-certificates" "/etc/pki/trust/anchors/" "update-ca-certificates"
elif grep -q "Ubuntu" /etc/*-release; then
    update_ca_certs "apt-get update && apt-get install -y ca-certificates" "/usr/local/share/ca-certificates/" "update-ca-certificates"
else
    echo "System not recognized"
    exit 1
fi

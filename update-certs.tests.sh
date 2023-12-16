#!/bin/bash

# Array of Docker images for different systems
DOCKER_IMAGES=("alpine:latest" "amazonlinux:latest" "archlinux:latest" "centos:latest" "debian:latest" "fedora:latest" "opensuse/leap:latest" "ubuntu:latest" "registry.access.redhat.com/ubi8/ubi:latest")
DOCKER_IMAGES_OVERRIDE="${1}"
if [ -n "${DOCKER_IMAGES_OVERRIDE}" ]; then
    DOCKER_IMAGES=("${DOCKER_IMAGES_OVERRIDE}")
fi

set -euo pipefail

# Run the mitmproxy Docker container
docker stop mitmproxy 2>/dev/null >/dev/null || true
MITMPROXY_CONTAINER_ID=$(docker run --rm -d --name mitmproxy mitmproxy/mitmproxy mitmdump)
trap "docker stop $MITMPROXY_CONTAINER_ID > /dev/null && echo Container mitmproxy has stopped." EXIT
MITMPROXY_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mitmproxy)

# Wait for the container to be ready
while [ "$(docker inspect -f '{{.State.Running}}' mitmproxy)" != "true" ]; do
  echo "Waiting for container mitmproxy to be ready..."
  sleep 1
done

sleep 1
echo "Container mitmproxy is ready."

# Copy the mitmproxy CA certificate from the container to the host
mkdir -p test-certs
docker cp mitmproxy:/home/mitmproxy/.mitmproxy/mitmproxy-ca-cert.pem ./test-certs/mitmproxy-ca-cert.crt

# Initialize an empty array to store the results
RESULTS=()

# Loop through the Docker images
for IMAGE in "${DOCKER_IMAGES[@]}"; do
    echo -n "Running test for $IMAGE ... "

    # Run the shell script in the Docker container
    DOCKER_CMD="docker run --rm -it --user root -e HTTPS_PROXY=$MITMPROXY_IP:8080 -v $(pwd)/update-certs.sh:/update-certs.sh -v $(pwd)/test-certs:/proxy-certs $IMAGE /bin/sh -c \"/update-certs.sh /proxy-certs\""
    set +euo pipefail
    if [ -n "${DOCKER_IMAGES_OVERRIDE}" ]; then
        eval $DOCKER_CMD
    else
        eval $DOCKER_CMD >/dev/null
    fi
    # Store the exit code
    EXIT_CODE=$?
    set -euo pipefail

    # Add the result to the array
    if [ $EXIT_CODE -eq 0 ]; then
        echo ✅ Passed
    else
        echo ❌ Failed
    fi
done

# Print a summary table of success and failures
# echo "Summary:"
# printf '%s\n' "${RESULTS[@]}"

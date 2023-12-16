#!/bin/bash

set -euo pipefail

# Run the mitmproxy Docker container
docker stop mitmproxy 2>/dev/null >/dev/null || true
MITMPROXY_CONTAINER_ID=$(docker run --rm -d --name mitmproxy mitmproxy/mitmproxy mitmdump)
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

# Array of Docker images for different systems
DOCKER_IMAGES=("alpine:latest" "amazonlinux:latest" "archlinux:latest" "centos:latest" "debian:latest" "fedora:latest" "opensuse/leap:latest" "ubuntu:latest" "registry.access.redhat.com/ubi8/ubi:latest")
# DOCKER_IMAGES=("alpine:latest")
# DOCKER_IMAGES=("amazonlinux:latest")
# DOCKER_IMAGES=("archlinux:latest")
# DOCKER_IMAGES=("centos:latest")
# DOCKER_IMAGES=("debian:latest")
# DOCKER_IMAGES=("fedora:latest")
# DOCKER_IMAGES=("opensuse/leap:latest")
# DOCKER_IMAGES=("ubuntu:latest")
# DOCKER_IMAGES=("registry.access.redhat.com/ubi8/ubi:latest")

# Initialize an empty array to store the results
RESULTS=()

# Loop through the Docker images
for IMAGE in "${DOCKER_IMAGES[@]}"; do
    echo "Running script in $IMAGE..."

    set +euo pipefail
    # Run the shell script in the Docker container
    docker run --rm -it --user root -e HTTPS_PROXY=$MITMPROXY_IP:8080 -v $(pwd)/update-certs.sh:/update-certs.sh -v $(pwd)/test-certs:/proxy-certs $IMAGE /bin/sh -c "/update-certs.sh /proxy-certs"
    # Store the exit code
    EXIT_CODE=$?

    set -euo pipefail

    # Add the result to the array
    if [ $EXIT_CODE -eq 0 ]; then
        RESULTS+=("$IMAGE: Success")
    else
        RESULTS+=("$IMAGE: Failure")
    fi
done

# Print a summary table of success and failures
echo "Summary:"
printf '%s\n' "${RESULTS[@]}"

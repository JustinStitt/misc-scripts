#!/usr/bin/env bash

trap 'exit' INT

# Make sure we have the required binaries
for NAME in podman docker; do
    command -v "${NAME}" &>/dev/null && BINARY=${NAME}
done
if [[ -z ${BINARY} ]]; then
    echo "Neither podman nor docker could be found on your system! Please install one to use this script."
    exit 1
fi

# Useful links for bumping versions
#
# Debian:
#   * https://www.debian.org/releases/
#   * https://wiki.debian.org/LTS
#   * https://hub.docker.com/_/debian
#
# Fedora:
#   * https://fedoraproject.org/wiki/Releases
#   * https://fedoraproject.org/wiki/End_of_life
#   * https://hub.docker.com/_/fedora
#
# OpenSUSE:
#   * https://en.opensuse.org/openSUSE:Roadmap
#   * https://en.opensuse.org/Lifetime
#   * https://hub.docker.com/r/opensuse/leap
#
# Ubuntu:
#   * https://wiki.ubuntu.com/Releases
#   * https://hub.docker.com/_/ubuntu
#
# This list should only include versions that are actively being supported.
#
# Tags such as "latest", "stable", or "rolling" are preferred so that the list
# does not have to be constantly updated. Old but supported releases like
# Fedora or OpenSUSE are the exception.
DOCKER_DISTROS=(
    archlinux:latest

    debian:oldoldstable-slim
    debian:oldstable-slim
    debian:stable-slim
    debian:testing-slim
    debian:unstable-slim

    fedora:34
    fedora:latest
    fedora:rawhide

    opensuse/leap:15.2
    opensuse/leap:latest
    opensuse/tumbleweed:latest

    ubuntu:bionic
    ubuntu:latest
    ubuntu:hirsute
    ubuntu:rolling
    ubuntu:devel
)

BASE=$(dirname "$(readlink -f "${0}")")

rm "${BASE}"/results.log

for DISTRO in "${DOCKER_DISTROS[@]}"; do
    DISTRO=docker.io/${DISTRO}
    "${BINARY}" pull "${DISTRO}"
    "${BINARY}" run \
        --rm \
        --init \
        --volume="${BASE}:${BASE}" \
        --workdir="${BASE}" \
        "${DISTRO}" \
        "${BASE}"/install-check-clang-version.sh "${DISTRO}"
done

echo
cat "${BASE}"/results.log
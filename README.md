# OS Cert Authority Guide
​
This document provides a guide on managing Certificate Authority (CA) certificates across various operating systems and distributions.

​
Certificate Authorities (CAs) are entities that issue digital certificates. These digital certificates are used to create secure connections via TLS/SSL (Transport Layer Security/Secure Sockets Layer). Managing these certificates involves adding new ones to your system and updating the ones that are already installed.
​

The table provided in this document serves as a guide for managing CA certificates on different operating systems. It includes information about identifying the operating system, installing the certificate management applications, adding new CA certificates, and more.

​
Remember to run commands with the necessary permissions (usually as root). Be aware that making changes to your system's certificates can have significant effects and should only be done if you understand the implications. Always back up your system before making changes. If you're unsure, consult with a system administrator or a trusted expert.
​
​
## CA Certificates Management Table
​
| System | Command to identify system | Command to add new CA certs | Command to install cert management tool | Folder in which to put new CA certs before calling the cert management tool | Docker Tag |
|--------|----------------------------|-----------------------------|-----------------------------------------|----------------------------|------------|
| Alpine | `cat /etc/*-release \| grep "Alpine Linux"` | `update-ca-certificates` | `apk add ca-certificates` | `/usr/local/share/ca-certificates/` | alpine:latest |
| Amazon Linux | `cat /etc/*-release \| grep "Amazon Linux"` | `update-ca-trust extract` | `yum install ca-certificates` | `/etc/pki/ca-trust/source/anchors/` | amazonlinux:latest |
| Arch | `cat /etc/*-release \| grep "Arch Linux"` | `trust extract-compat` | `pacman -Sy ca-certificates-utils` | `/etc/ca-certificates/trust-source/anchors/` | archlinux:latest |
| CentOS | `cat /etc/*-release \| grep CentOS` | `update-ca-trust extract` | `yum install ca-certificates` | `/etc/pki/ca-trust/source/anchors/` | centos:latest |
| CoreOS | `cat /etc/*-release \| grep CoreOS` | `update-ca-certificates` | Built into the system | `/etc/pki/ca-trust/source/anchors/` | Not available |
| Debian | `cat /etc/*-release \| grep Debian` | `update-ca-certificates` | `apt-get update && apt-get install -y ca-certificates` | `/usr/local/share/ca-certificates/` | debian:latest |
| Fedora | `cat /etc/*-release \| grep Fedora` | `update-ca-trust extract` | `dnf install ca-certificates` | `/etc/pki/ca-trust/source/anchors/` | fedora:latest |
| MacOS | `uname -a \| grep Darwin` | `security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain <path_to_cert>` | Built into the system | `/Library/Keychains/System.keychain` | Not available |
| RedHat | `cat /etc/*-release \| grep "Red Hat"` | `update-ca-trust extract` | `yum install ca-certificates` | `/etc/pki/ca-trust/source/anchors/` | registry.access.redhat.com/ubi8/ubi:latest |
| SUSE | `cat /etc/*-release \| grep SUSE` | `update-ca-certificates` | `zypper install ca-certificates` | `/etc/pki/trust/anchors/` | opensuse/leap:latest |
| Ubuntu | `cat /etc/*-release \| grep Ubuntu` | `update-ca-certificates` | `apt-get update && apt-get install -y ca-certificates` | `/usr/local/share/ca-certificates/` | ubuntu:latest |
| Windows | - | `certutil -addstore -f "Root" <path_to_cert>` | Built into the system | `C:\Windows\System32\certsrv\CertEnroll\` | mcr.microsoft.com/windows/servercore:ltsc2019 |
​
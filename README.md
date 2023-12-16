# OS Cert Authority Guide
​
This document provides a guide on managing Certificate Authority (CA) certificates across various operating systems and distributions.

​
Certificate Authorities (CAs) are entities that issue digital certificates. These digital certificates are used to create secure connections via TLS/SSL (Transport Layer Security/Secure Sockets Layer). Managing these certificates involves adding new ones to your system and updating the ones that are already installed.
​

The table provided in this document serves as a guide for managing CA certificates on different operating systems. It includes information about installing the certificate management applications and adding new CA certificates.

​
Remember to run commands with the necessary permissions (usually as root). Be aware that making changes to your system's certificates can have significant effects and should only be done if you understand the implications. Always back up your system before making changes. If you're unsure, consult with a system administrator or a trusted expert.
​
​
## Operating System Cert Management
​
| System | Copy new certs here | Command to trust new certs | Install cert management tool |
|--------|---------------------|----------------------------|------------------------------|
| Alpine | `/usr/local/share/ca-certificates/` | `update-ca-certificates` | `apk add ca-certificates` |
| Amazon Linux | `/etc/pki/ca-trust/source/anchors/` | `update-ca-trust extract` | `yum install ca-certificates` |
| Arch | `/etc/ca-certificates/trust-source/anchors/` | `trust extract-compat` | `pacman -Sy ca-certificates-utils` |
| CentOS | `/etc/pki/ca-trust/source/anchors/` | `update-ca-trust extract` | `yum install ca-certificates` |
| CoreOS | `/etc/pki/ca-trust/source/anchors/` | `update-ca-certificates` | Built into the system |
| Debian | `/usr/local/share/ca-certificates/` | `update-ca-certificates` | `apt-get install -y ca-certificates` |
| Fedora | `/etc/pki/ca-trust/source/anchors/` | `update-ca-trust extract` | `dnf install ca-certificates` |
| MacOS | `/Library/Keychains/System.keychain` | `security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain <path_to_cert>` | Built into the system |
| RedHat | `/etc/pki/ca-trust/source/anchors/` | `update-ca-trust extract` | `yum install ca-certificates` |
| SUSE | `/etc/pki/trust/anchors/` | `update-ca-certificates` | `zypper install ca-certificates` |
| Ubuntu | `/usr/local/share/ca-certificates/` | `update-ca-certificates` | `apt-get install -y ca-certificates` |
| Windows | `C:\Windows\System32\certsrv\CertEnroll\` | `certutil -addstore -f "Root" <path_to_cert>` | Built into the system |

## Using update-certs.sh

This repository includes a script, `update-certs.sh`, designed to simplify the process of adding new certificates on various Linux distributions (refer to the table above for supported distributions).

Follow these steps to use the script:

1. Transfer the `update-certs.sh` script to your Linux system.
2. Place the new certificate(s) in a known location on your system. The script will handle moving these certificate(s) to the appropriate system-specific directory (as listed in the table above).
3. Execute the script, providing the path to the certificate(s) as an argument. For example: `sh update-certs.sh /path/to/your/certificate-or-directory`
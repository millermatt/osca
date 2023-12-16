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
<table>
    <thead>
        <tr>
            <th>System</th>
            <th>Copy new certs here</th>
            <th>Command to trust new certs</th>
            <th>Install cert management tool</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Alpine</td>
            <td>/usr/local/share/ca-certificates/</td>
            <td>update-ca-certificates</td>
            <td>apk add ca-certificates</td>
        </tr>
        <tr>
            <td>Amazon Linux</td>
            <td>/etc/pki/ca-trust/source/anchors/</td>
            <td>update-ca-trust extract</td>
            <td>yum install ca-certificates</td>
        </tr>
        <tr>
            <td>Arch</td>
            <td>/etc/ca-certificates/trust-source/anchors/</td>
            <td>trust extract-compat</td>
            <td>pacman -Sy ca-certificates-utils</td>
        </tr>
        <tr>
            <td>CentOS</td>
            <td>/etc/pki/ca-trust/source/anchors/</td>
            <td>update-ca-trust extract</td>
            <td>yum install ca-certificates</td>
        </tr>
        <tr>
            <td>CoreOS</td>
            <td>/etc/pki/ca-trust/source/anchors/</td>
            <td>update-ca-certificates</td>
            <td>Built into the system</td>
        </tr>
        <tr>
            <td>Debian</td>
            <td>/usr/local/share/ca-certificates/</td>
            <td>update-ca-certificates</td>
            <td>apt-get install -y ca-certificates</td>
        </tr>
        <tr>
            <td>Fedora</td>
            <td>/etc/pki/ca-trust/source/anchors/</td>
            <td>update-ca-trust extract</td>
            <td>dnf install ca-certificates</td>
        </tr>
        <tr>
            <td>MacOS</td>
            <td>/Library/Keychains/System.keychain</td>
            <td>security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain &lt;path_to_cert&gt;</td>
            <td>Built into the system</td>
        </tr>
        <tr>
            <td>RedHat</td>
            <td>/etc/pki/ca-trust/source/anchors/</td>
            <td>update-ca-trust extract</td>
            <td>yum install ca-certificates</td>
        </tr>
        <tr>
            <td>SUSE</td>
            <td>/etc/pki/trust/anchors/</td>
            <td>update-ca-certificates</td>
            <td>zypper install ca-certificates</td>
        </tr>
        <tr>
            <td>Ubuntu</td>
            <td>/usr/local/share/ca-certificates/</td>
            <td>update-ca-certificates</td>
            <td>apt-get install -y ca-certificates</td>
        </tr>
        <tr>
            <td>Windows</td>
            <td>C:\Windows\System32\certsrv\CertEnroll\</td>
            <td>certutil -addstore -f "Root" &lt;path_to_cert&gt;</td>
            <td>Built into the system</td>
        </tr>
    </tbody>
</table>
## Guidelines for new certificate files

- Each certificate file should contain only one certificate.
- Certificates must be in the PEM format.
- Use the `.crt` extension for certificate files to ensure maximum compatibility across different systems. While some certificate management tools are indifferent to the file extension, others require the `.crt` extension. Therefore, it's best to consistently use this extension.

## PEM format

PEM is a widely used encoding format for SSL certificates. PEM formatted certificates are ASCII (Base64) encoded and include "-----BEGIN CERTIFICATE-----" and "-----END CERTIFICATE-----" lines.

To convert certificates in other formats to PEM, you can use [OpenSSL](https://www.openssl.org/), a robust toolkit for the Transport Layer Security (TLS) and Secure Sockets Layer (SSL) protocols. Here are some commands for converting from popular formats to PEM:

- DER to PEM:
    ```
    openssl x509 -inform der -in certificate.der -out certificate.pem
    ```

- PKCS#12 (PFX) to PEM:
    ```
    openssl pkcs12 -in certificate.pfx -out certificate.pem -nodes
    ```

- PKCS#7 to PEM:
    ```
    openssl pkcs7 -print_certs -in certificate.p7b -out certificate.pem
    ```

Remember to replace certificate.der, certificate.pfx, and certificate.p7b with the path to your certificate file. The converted certificates will be saved as certificate.pem.

## Using update-certs.sh

This repository includes a script, `update-certs.sh`, designed to simplify the process of adding new certificates on various Linux distributions (refer to the table above for supported distributions).

Follow these steps to use the script:

1. Transfer the `update-certs.sh` script to your Linux system.
2. Place the new certificate(s) in a known location on your system. The script will handle moving these certificate(s) to the appropriate system-specific directory (as listed in the table above).
3. Execute the script, providing the path to the certificate(s) as an argument. For example: `sh update-certs.sh /path/to/your/certificate-or-directory`

## Using update-certs.sh with Docker

The `update-certs.sh` script can also be used within a Docker container. This is particularly useful when you are running Docker behind a corporate proxy that injects man in the middle certs.

1. Obtain a copy of the proxy certs and copy the file[s] to your Docker host
1. Run the Docker container, and mount the `update-certs.sh` script and the file or directory containing your new certificates into the container. For example:

    ```shell
    docker run --rm -it --user root -v $(pwd)/update-certs.sh:/update-certs.sh -v /path/to/cert/file-or-folder:/proxy-certs alpine:latest /bin/sh -c "/update-certs.sh /proxy-certs"
    ```

    This command runs the `update-certs.sh` script inside the Docker container, with `/proxy-certs` as the argument. The script will copy the certificates from `/proxy-certs` to the appropriate directory in the container and update the system's trust store.

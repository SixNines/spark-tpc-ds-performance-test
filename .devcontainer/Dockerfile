FROM mcr.microsoft.com/devcontainers/base:jammy

WORKDIR /build

COPY setup/* ./

RUN <<EOF
tar -xzf "tpc-ds-tools-$(uname -p).tar.gz" -C /usr/local/bin --strip-components 1
rm -f tpc-ds-tools-*.tar.gz
EOF

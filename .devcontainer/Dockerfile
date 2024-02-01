FROM mcr.microsoft.com/devcontainers/base:jammy

WORKDIR /build

COPY setup/* ./

RUN <<EOF
tar -xzf "tpc-ds-tools-$(uname -p).tar.gz" -C /usr/local/bin --strip-components 1
rm -f tpc-ds-tools-*.tar.gz
EOF

RUN <<EOF
apt-get update
apt-get install -y \
    openjdk-8-jdk
rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
SPARK_VERSION="spark-3.3.4-bin-hadoop3-scala2.13"
FILENAME="${SPARK_VERSION}.tgz"
URLBASE="https://downloads.apache.org/spark/spark-3.3.4/${FILENAME}"

curl -LO "$URLBASE"
curl -LO "$URLBASE.sha512"
curl -LO "$URLBASE.asc"
sha512sum -c "${FILENAME}.sha512"
curl -L https://www.apache.org/dist/spark/KEYS | gpg --import
gpg --verify "${FILENAME}.asc" "${FILENAME}"
tar -xzf $FILENAME -C /opt
ln -s /opt/$SPARK_VERSION /opt/spark
rm -f ${FILENAME}*
chown -R vscode:vscode /opt/$SPARK_VERSION/*

cat <<EOF2 > /etc/profile.d/spark.sh
export SPARK_HOME=/opt/spark
export PATH=\$PATH:\$SPARK_HOME/bin
EOF2
EOF

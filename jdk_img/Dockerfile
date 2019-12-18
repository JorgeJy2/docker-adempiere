FROM debian:stretch

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64" && \
apt update && \
apt install -y openjdk-8-jdk --no-install-recommends && \
rm -rf /var/lib/apt/lists/* 
FROM jdk_adempiere:8

ARG ADEMPIERE_BINARY
ARG ADEMPIERE_SRC_DIR

ENV ADEMPIERE_BINARY $ADEMPIERE_BINARY
ENV ADEMPIERE_SRC_DIR $ADEMPIERE_SRC_DIR
ENV ADEMPIERE_HOME /opt/Adempiere

COPY $ADEMPIERE_SRC_DIR/$ADEMPIERE_BINARY /tmp

RUN cd /tmp && \
tar zxvf /tmp/$ADEMPIERE_BINARY && \
mv Adempiere /opt/Adempiere && \
sed -i "s/ADEMPIERE_HOME=C.*/ADEMPIERE_HOME=\/opt\/Adempiere/g" /opt/Adempiere/AdempiereEnvTemplate.properties && \
sed -i "s/JAVA_HOME=C.*/JAVA_HOME=\/usr\/lib\/jvm\/java-8-openjdk-amd64/g" /opt/Adempiere/AdempiereEnvTemplate.properties && \
sed -i "s/ADEMPIERE_JAVA_OPTIONS=-Xms64M -Xmx512M/ADEMPIERE_JAVA_OPTIONS=-Xms1024M -Xmx4096M/g" /opt/Adempiere/AdempiereEnvTemplate.properties && \
JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64" && \
apt update && \
apt install -y postgresql postgresql-contrib --no-install-recommends && \
rm -rf /var/lib/apt/lists/*
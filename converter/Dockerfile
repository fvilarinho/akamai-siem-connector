FROM alpine:3.19.1

# File Author / Maintainer.
LABEL maintainer="Felipe Vilarinho <fvilarin@akamai.com>"

# Environment variables.
ENV HOME_DIR=/home/converter
ENV BIN_DIR=${HOME_DIR}/bin
ENV ETC_DIR=${HOME_DIR}/etc
ENV LIBS_DIR=${HOME_DIR}/lib
ENV LOGS_DIR=${HOME_DIR}/logs

# Install dependencies.
RUN apk update && \
    apk add --no-cache bash ca-certificates curl nss unzip openjdk17-jre

# Create default directory structure.
RUN mkdir -p ${HOME_DIR} ${BIN_DIR} ${ETC_DIR} ${LIBS_DIR} ${LOGS_DIR}

# Setup the binary and configurations.
COPY src/main/resources/bin ${BIN_DIR}
COPY src/main/resources/etc/banner.txt ${ETC_DIR}/
COPY src/main/resources/etc/settings.json.original ${ETC_DIR}/settings.json
COPY src/main/resources/etc/templates.json ${ETC_DIR}/templates.json
COPY build/distributions/converter.zip /home

RUN cd /home && \
    unzip /home/converter.zip && \
    rm converter.zip && \
    rm ${BIN_DIR}/converter.bat && \
    mv ${BIN_DIR}/converter ${BIN_DIR}/run.sh

# Define the permissions and entrypoint file.
RUN addgroup -S converter && \
    adduser -S converter -G converter && \
    chown -R converter:converter ${HOME_DIR} && \
    chmod +x ${BIN_DIR}/*.sh && \
    ln -s ${BIN_DIR}/startup.sh /entrypoint.sh

# Default user.
USER converter

# Default work directory.
WORKDIR ${HOME_DIR}

ENTRYPOINT ["/entrypoint.sh"]
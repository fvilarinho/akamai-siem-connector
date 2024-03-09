FROM alpine:3.19.1

# File Author / Maintainer.
LABEL maintainer="Felipe Vilarinho <fvilarin@akamai.com>"

# Install the dependencies.
RUN apk update && \
    apk add --no-cache bash shadow ca-certificates curl jq su-exec mosquitto mosquitto-clients && \
    chmod u+s /sbin/su-exec

# Environment variables.
ENV HOME_DIR=/home/scheduler
ENV BIN_DIR=${HOME_DIR}/bin
ENV ETC_DIR=${HOME_DIR}/etc
ENV DATA_DIR=${HOME_DIR}/data
ENV LOGS_DIR=${HOME_DIR}/logs

# Create default work structure.
RUN mkdir -p ${HOME_DIR} ${BIN_DIR} ${ETC_DIR} ${DATA_DIR} ${LOGS_DIR}

# Adding startup and configuration files.
COPY bin ${BIN_DIR}
COPY etc/banner.txt ${ETC_DIR}/
COPY etc/settings.conf.original ${ETC_DIR}/settings.conf
COPY etc/settings.json.original ${ETC_DIR}/settings.json

# Configure the scheduling and startup.
RUN rm -f /etc/crontabs/root && \
    echo "* * * * * /home/scheduler/bin/run.sh" > /etc/crontabs/root

# Define default permissions.
RUN addgroup -S scheduler && \
    adduser -S scheduler -G scheduler && \
    chown -R scheduler:scheduler ${HOME_DIR} && \
    chmod +x ${BIN_DIR}/*.sh && \
    ln -s ${BIN_DIR}/startup.sh /entrypoint.sh

# Define default user.
USER scheduler

# Defune default work directory.
WORKDIR ${HOME_DIR}

# Expose ports.
EXPOSE 1883

ENTRYPOINT [ "/entrypoint.sh" ]
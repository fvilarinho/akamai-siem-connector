FROM alpine:3.19.1

# File Author / Maintainer.
LABEL maintainer="Felipe Vilarinho <fvilarin@akamai.com>"

# Install the dependencies.
RUN apk update && \
    apk add --no-cache bash ca-certificates curl nodejs

# Environment variables.
ENV HOME_DIR=/home/consumer
ENV BIN_DIR=${HOME_DIR}/bin
ENV ETC_DIR=${HOME_DIR}/etc
ENV LIBS_DIR=${HOME_DIR}/libs
ENV LOGS_DIR=${HOME_DIR}/logs
ENV NODE_PATH=${LIBS_DIR}

# Create default work structure.
RUN mkdir -p ${HOME_DIR} ${BIN_DIR} ${ETC_DIR} ${LIBS_DIR} ${LOGS_DIR}

# Adding startup and configuration files.
COPY bin ${BIN_DIR}
COPY etc/banner.txt ${ETC_DIR}/
COPY etc/settings.json.original ${ETC_DIR}/settings.json
COPY src/*.js ${BIN_DIR}/
COPY src/node_modules ${LIBS_DIR}

# Define default permissions.
RUN addgroup -S consumer && \
    adduser -S consumer -G consumer && \
    chown -R consumer:consumer ${HOME_DIR} && \
    chmod +x ${BIN_DIR}/*.sh && \
    ln -s ${BIN_DIR}/startup.sh /entrypoint.sh

# Define default user.
USER consumer

# Define default work directory.
WORKDIR ${HOME_DIR}

ENTRYPOINT [ "/entrypoint.sh" ]
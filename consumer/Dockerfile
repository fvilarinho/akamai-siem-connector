# Receive build attributes.
ARG DOCKER_REGISTRY_URL
ARG DOCKER_REGISTRY_ID
ARG IDENTIFIER
ARG BUILD_VERSION
FROM ${DOCKER_REGISTRY_URL}/${DOCKER_REGISTRY_ID}/base-consumer:${BUILD_VERSION}

# File Author / Maintainer.
LABEL maintainer="Felipe Vilarinho <fvilarin@akamai.com>"

# Adding startup and configuration files.
COPY etc/banner.txt ${ETC_DIR}/
COPY etc/settings.json.original ${ETC_DIR}/settings.json
COPY src/*.js ${BIN_DIR}/
COPY src/node_modules ${LIBS_DIR}
FROM alpine:3.19.4

# File Author / Maintainer,
LABEL maintainer="Felipe Vilarinho <fvilarin@akamai.com>"

# Install the dependencies.
RUN apk update && \
    apk add --no-cache bash ca-certificates curl nginx apache2-utils

# Environment variables.
ENV HOME_DIR=/home/ingress
ENV BIN_DIR=${HOME_DIR}/bin
ENV ETC_DIR=${HOME_DIR}/etc
ENV HTDOCS_DIR=${HOME_DIR}/htdocs
ENV LOGS_DIR=${HOME_DIR}/logs

# Create default work structure.
RUN mkdir -p ${HOME_DIR} ${BIN_DIR} ${ETC_DIR} ${HTDOCS_DIR} ${LOGS_DIR} && \
    rm -f /etc/nginx/http.d/default.conf

# Adding startup and configuration files.
COPY bin ${BIN_DIR}
COPY etc/banner.txt ${ETC_DIR}/
COPY etc/nginx/http.d/settings.conf.original ${ETC_DIR}/nginx/http.d/settings.conf
COPY etc/ssl ${ETC_DIR}/ssl
COPY htdocs/index.html ${HTDOCS_DIR}/index.html
COPY htdocs/settings.js.original ${HTDOCS_DIR}/settings.js

# Define default permissions.
RUN chmod +x ${BIN_DIR}/*.sh && \
    ln -s ${BIN_DIR}/startup.sh /entrypoint.sh

# Define default work directory.
WORKDIR ${HOME_DIR}

ENTRYPOINT [ "/entrypoint.sh" ]
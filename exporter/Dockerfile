FROM opensearchproject/logstash-oss-with-opensearch-output-plugin:8.9.0

# File Author / Maintainer.
LABEL maintainer="Felipe Vilarinho <fvilarin@akamai.com>"

# Copy required files.
COPY bin/setup.sh /usr/local/bin/setup.sh
COPY bin/startup.sh /usr/local/bin/startup.sh
COPY etc/settings.conf.original /usr/share/logstash/pipeline/logstash.conf
COPY etc/plugins.conf /usr/share/logstash/config/plugins.conf

USER root

RUN chmod +x /usr/local/bin/*.sh && \
    ln -s /usr/local/bin/startup.sh /entrypoint.sh

USER logstash

ENTRYPOINT [ "/entrypoint.sh" ]
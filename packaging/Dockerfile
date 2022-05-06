FROM ubuntu:22.04
MAINTAINER "Francisco J. Valero <fvalero86@gmail.com>"
LABEL Description="Test for algo"

RUN apt-get update
RUN apt-get install -y git curl npm nvme-cli

RUN git clone https://github.com/algolia/instant-search-demo.git /opt/instant-search-demo

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

COPY ./docker-entrypoint.sh /
RUN chmod 700 /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]

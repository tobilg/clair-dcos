FROM quay.io/coreos/clair:v1.2.6

ENV CLAIR_DCOS_PATH /clair-dcos

RUN apk add --no-cache wget bash && \
    mkdir -p $CLAIR_DCOS_PATH && \
    wget -qO- https://github.com/jwilder/dockerize/releases/download/v0.4.0/dockerize-alpine-linux-amd64-v0.4.0.tar.gz | tar xvz -C /usr/local/bin

ADD clair-entrypoint.sh $CLAIR_DCOS_PATH

ADD config.yaml.template $CLAIR_DCOS_PATH

ENTRYPOINT ["/clair-dcos/clair-entrypoint.sh"]
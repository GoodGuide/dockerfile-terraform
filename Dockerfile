FROM quay.io/goodguide/base:alpine-3.6

RUN apk --update add \
      bash \
      curl \
      git \
      ncurses \
      zip

RUN version=0.10.4 shasum='cff83f669d0e4ac315e792a57659d5aae8ea1fcfdca6931c7cc4679b4e6c60e3' \
 && cd /tmp \
 && curl -L -o ./terraform.zip "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip" \
 && sha256sum ./terraform.zip | grep -q "${shasum}" \
 && unzip ./terraform.zip \
 && install ./terraform /usr/local/bin/

COPY ./entrypoint.sh /bin/_entrypoint
ENTRYPOINT ["/sbin/tini", "-g", "--", "/bin/_entrypoint"]

VOLUME /terraform
WORKDIR /terraform

CMD ["help"]

FROM quay.io/goodguide/base:alpine-3.5

RUN apk --update add \
      bash \
      curl \
      git \
      ncurses \
      zip

RUN version=0.8.5 shasum='4b4324e354c26257f0b830eacb0e7cc7e2ced017d78855f74cb9377f1abf1dd7' \
 && cd /tmp \
 && curl -L -o ./terraform.zip "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip" \
 && sha256sum ./terraform.zip | grep -q "${shasum}" \
 && unzip ./terraform.zip \
 && install ./terraform /usr/local/bin/

COPY ./entrypoint.sh /bin/_entrypoint
ENTRYPOINT ["/bin/_entrypoint"]

VOLUME /terraform
WORKDIR /terraform

CMD ["help"]

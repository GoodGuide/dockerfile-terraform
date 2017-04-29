FROM quay.io/goodguide/base:alpine-3.5

RUN apk --update add \
      bash \
      curl \
      git \
      ncurses \
      zip

RUN version=0.9.4 shasum='cc1cffee3b82820b7f049bb290b841762ee920aef3cf4d95382cc7ea01135707' \
 && cd /tmp \
 && curl -L -o ./terraform.zip "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip" \
 && sha256sum ./terraform.zip | grep -q "${shasum}" \
 && unzip ./terraform.zip \
 && install ./terraform /usr/local/bin/

COPY ./entrypoint.sh /bin/_entrypoint
ENTRYPOINT ["/sbin/tini", "-vvg", "--", "/bin/_entrypoint"]

VOLUME /terraform
WORKDIR /terraform

CMD ["help"]

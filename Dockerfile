FROM quay.io/goodguide/base:alpine-3.6

RUN apk --update add \
      bash \
      curl \
      git \
      ncurses \
      zip

RUN version=0.10.0 shasum='f991039e3822f10d6e05eabf77c9f31f3831149b52ed030775b6ec5195380999' \
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

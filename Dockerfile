FROM alpine

RUN set -x \
 && apk --update add \
      bash \
      curl \
      git \
      jq \
      ncurses \
      py-pip \
      zip \

 && rm -rf /tmp/*

RUN set -x \
 && pip install awscli

RUN set -x \
 && export url='https://releases.hashicorp.com/terraform/0.7.2/terraform_0.7.2_linux_amd64.zip' shasum='c34afce79ee78b3b1a1a5ab7204bba0173c61ce3' \
 && cd /tmp \
 && curl -L -o ./terraform.zip "${url}" \
 && sha1sum ./terraform.zip | grep -q "${shasum}" \
 && unzip ./terraform.zip \
 && install ./terraform /usr/local/bin/

COPY ./bashrc /root/.bashrc

COPY ./entrypoint.sh /bin/_entrypoint
ENTRYPOINT ["/bin/_entrypoint"]

VOLUME /terraform
WORKDIR /terraform

CMD ["bash"]

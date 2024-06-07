FROM alpine:3.18

LABEL "maintainer"="daniel.mejia@pnnl.gov"

RUN apk add --no-cache git git-lfs openssh-client && \
  echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

ADD *.sh /

ENTRYPOINT ["/entrypoint.sh"]

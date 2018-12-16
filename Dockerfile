FROM alpine:edge as builder

RUN cd /opt && \
  apk --update add wget gcc libffi-dev git make python3-dev musl-dev tzdata postgresql-dev && \
  ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  git clone https://github.com/jumpserver/jumpserver.git && \
  cd /opt/jumpserver/requirements && \
  sed -ie 's/libressl-dev//' alpine_requirements.txt && \
  apk add $(cat alpine_requirements.txt) && \
  pip3 install --upgrade pip setuptools && \
  pip install -r requirements.txt

FROM alpine:edge

COPY --from=builder /opt/jumpserver /opt/jumpserver/
COPY --from=builder /usr/lib/python3.6 /usr/lib/python3.6/

WORKDIR /opt/jumpserver

RUN \
  ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  sed -ie 's/-dev//g' requirements/alpine_requirements.txt && \
  apk --update add $(cat requirements/alpine_requirements.txt) python3 tzdata postgresql-libs && \
  ln -sf /usr/bin/python3 /usr/bin/python


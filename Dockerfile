FROM debian:10.2-slim as runtime

RUN mkdir -p /app/data && chown nobody:nogroup /app/data
RUN mkdir -p /mnt/bee

RUN wget https://github.com/ethersphere/bee-clef/releases/download/v0.4.7/bee-clef_0.4.7_amd64.deb

COPY packaging/rules.js /app/config/rules.js
COPY packaging/4byte.json /app/config/4byte.json
COPY packaging/docker/entrypoint.sh /entrypoint.sh

EXPOSE 8550
USER nobody
WORKDIR /app
VOLUME /app/data

ENTRYPOINT ["/entrypoint.sh"]

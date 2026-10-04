FROM alpine:3.22
RUN apk add --no-cache ffmpeg icecast
COPY icecast.xml /etc/airports-radio/icecast.xml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
EXPOSE 8000
VOLUME /music
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

FROM ubuntu:xenial
RUN wget -qO- https://get.docker.com/ | sh
COPY ./src /app
CMD ["/app/update.sh"]
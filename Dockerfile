FROM ubuntu:xenial
RUN apt-get -qq update
RUN apt-get -qq -y install wget
RUN wget -qO- https://get.docker.com/ | sh
COPY ./src /app
CMD ["/app/update.sh"]
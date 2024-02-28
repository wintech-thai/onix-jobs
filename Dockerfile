FROM ubuntu:latest

RUN apt-get update -y
RUN apt-get install -y supervisor tor wget curl unzip vim
RUN apt-get install -y postgresql-client postgresql-client-common libpq-dev

WORKDIR /scripts
COPY scripts/ .

RUN pwd; ls -al

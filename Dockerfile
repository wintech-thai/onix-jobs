FROM ubuntu:latest

RUN apt-get update -y
RUN apt-get install -y supervisor tor wget curl unzip vim
RUN apt-get install -y postgresql-client postgresql-client-common libpq-dev

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin

WORKDIR /scripts
COPY scripts/ .

RUN pwd; ls -al
RUN kubectl

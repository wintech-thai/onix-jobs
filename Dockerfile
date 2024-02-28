FROM ubuntu:latest

RUN apt-get update -y
RUN apt-get install -y supervisor tor wget curl unzip vim apt-transport-https ca-certificates gnupg
RUN apt-get install -y postgresql-client postgresql-client-common libpq-dev

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin

RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN apt-get update && apt-get install google-cloud-cli

WORKDIR /scripts
COPY scripts/ .

RUN pwd; ls -al
RUN gcloud version

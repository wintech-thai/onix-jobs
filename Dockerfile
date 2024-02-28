FROM gcr.io/google.com/cloudsdktool/google-cloud-cli:latest

WORKDIR /scripts
COPY scripts/ .

RUN pwd; ls -al

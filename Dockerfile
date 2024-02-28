FROM gcr.io/google.com/cloudsdktool/google-cloud-cli:latest

RUN apk add --no-cache postgresql-client

WORKDIR /scripts
COPY scripts/ .

RUN pwd; ls -al

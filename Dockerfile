FROM gcr.io/google.com/cloudsdktool/google-cloud-cli:latest

RUN kubectl version
RUN gcloud -v

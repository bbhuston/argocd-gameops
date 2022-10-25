# FROM gcr.io/kpt-dev/kpt-gcloud:v1.0.0-beta.17
FROM  gcr.io/google.com/cloudsdktool/cloud-sdk:392.0.0-alpine

# Add support for GNU Make and other CLI tools
RUN apk update && apk add --no-cache make jq openssl && \
    gcloud components update && \
    gcloud --quiet components install alpha beta kubectl gke-gcloud-auth-plugin && \
    mv /google-cloud-sdk/bin/kubectl.1.24 /google-cloud-sdk/bin/kubectl && \
        gcloud version && \
        kubectl version --client=true && \
        make -v

ENTRYPOINT ["/bin/bash"]
ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG TARGETARCH
ARG TF_VERSION

# Switch to root to have permissions for operations
USER root

# terraform
ADD https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${TARGETARCH}.zip /usr/local/bin/terraform_${TF_VERSION}_linux_${TARGETARCH}.zip
RUN unzip -q /usr/local/bin/terraform_${TF_VERSION}_linux_${TARGETARCH}.zip && \
    rm /usr/local/bin/terraform_${TF_VERSION}_linux_${TARGETARCH}.zip && \
    chmod +x /usr/local/bin/terraform

# Switch back to the non-root user after operations
USER 65532:65532

ARG BASE_IMAGE

FROM python:3.10.5-alpine3.16 as aws-builder

ARG AWS_CLI_VERSION=2.7.20
RUN apk add --no-cache git unzip groff build-base libffi-dev cmake
RUN git clone --single-branch --depth 1 -b ${AWS_CLI_VERSION} https://github.com/aws/aws-cli.git

WORKDIR aws-cli
RUN sed -i'' 's/PyInstaller.*/PyInstaller==5.2/g' requirements-build.txt
RUN python -m venv venv
RUN . venv/bin/activate
RUN scripts/installers/make-exe
RUN unzip -q dist/awscli-exe.zip
RUN aws/install --bin-dir /aws-cli-bin

# reduce image size: remove autocomplete and examples
RUN rm -rf /usr/local/aws-cli/v2/current/dist/aws_completer /usr/local/aws-cli/v2/current/dist/awscli/data/ac.index /usr/local/aws-cli/v2/current/dist/awscli/examples
RUN find /usr/local/aws-cli/v2/current/dist/awscli/botocore/data -name examples-1.json -delete


FROM $BASE_IMAGE
ARG TARGETARCH
ARG INFRA_EXEC_VERSION
ARG INFRA_EXEC_URL_PREFIX
ARG INFRA_EXEC_NAME

# Switch to root to have permissions for operations
USER root

#aws-cli
COPY --from=aws-builder /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=aws-builder /aws-cli-bin/ /usr/local/bin/

# terraform
ADD ${INFRA_EXEC_URL_PREFIX}${INFRA_EXEC_VERSION}/${INFRA_EXEC_NAME}_${INFRA_EXEC_VERSION}_linux_${TARGETARCH}.zip ${INFRA_EXEC_NAME}_${INFRA_EXEC_VERSION}_linux_${TARGETARCH}.zip
RUN unzip -q ${INFRA_EXEC_NAME}_${INFRA_EXEC_VERSION}_linux_${TARGETARCH}.zip -d /usr/local/bin/ && \
    rm ${INFRA_EXEC_NAME}_${INFRA_EXEC_VERSION}_linux_${TARGETARCH}.zip && \
    mv /usr/local/bin/${INFRA_EXEC_NAME} /usr/local/bin/terraform && \
    chmod +x /usr/local/bin/terraform

# Switch back to the non-root user after operations
USER 65532:65532


ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG TARGETARCH
ARG INFRA_EXEC_VERSION
ARG INFRA_EXEC_URL_PREFIX
ARG INFRA_EXEC_NAME

# Switch to root to have permissions for operations
USER root

# terraform
ADD ${INFRA_EXEC_URL_PREFIX}${INFRA_EXEC_VERSION}/${INFRA_EXEC_NAME}_${INFRA_EXEC_VERSION}_linux_${TARGETARCH}.zip ${INFRA_EXEC_NAME}_${INFRA_EXEC_VERSION}_linux_${TARGETARCH}.zip
RUN unzip -q ${INFRA_EXEC_NAME}_${INFRA_EXEC_VERSION}_linux_${TARGETARCH}.zip -d /usr/local/bin/ && \
    rm ${INFRA_EXEC_NAME}_${INFRA_EXEC_VERSION}_linux_${TARGETARCH}.zip && \
    mv /usr/local/bin/${INFRA_EXEC_NAME} /usr/local/bin/terraform && \
    chmod +x /usr/local/bin/terraform

# Switch back to the non-root user after operations
USER 65532:65532

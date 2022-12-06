#
# Highest version of node with the highest version of npm < 8.5.0
#
# See: https://nodejs.org/en/download/releases/
# See: https://github.com/npm/cli/blob/latest/CHANGELOG.md#v850-2022-02-10
# See: https://github.com/npm/cli/issues/2546
#

ARG GCLOUD_TAG=410.0.0
ARG NODE_TAG=16.14.0-buster
ARG PROJECT_ID

FROM gcr.io/${PROJECT_ID}/node:${NODE_TAG} AS build

ARG TERRAFORM_VERSION=1.3.6
ARG TERRAFORM_VERSION_SHA256SUM=bb44a4c2b0a832d49253b9034d8ccbd34f9feeb26eda71c665f6e7fa0861f49b

ENV TERRAFORM_FILE=terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# build terraform
RUN curl -Lso ${TERRAFORM_FILE} --url "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_FILE}" && \
    echo "${TERRAFORM_VERSION_SHA256SUM}  ${TERRAFORM_FILE}" > checksum && sha256sum -c checksum                        && \
    unzip ${TERRAFORM_FILE}

FROM gcr.io/${PROJECT_ID}/gcloud:${GCLOUD_TAG}

ENV NODE_PATH=/usr/local/lib/node_modules

# copy terraform
COPY --from=build terraform /usr/bin/terraform
ADD entrypoint.bash /builder/entrypoint.bash
RUN chmod +x /builder/entrypoint.bash

# versions and limits
RUN . /usr/local/lib/utils.bash              && \
    print_versions node npm gcloud terraform && \
    echo '~===~ node limits ~===~'           && \
    sudo -u node sh -c 'ulimit -a'           && \
    echo '~===~ -*-*-*-*-*- ~===~'

ENTRYPOINT ["/builder/entrypoint.bash"]

#
# Highest version of node with the highest version of npm < 8.5.0
#
# See: https://nodejs.org/en/download/releases/
# See: https://github.com/npm/cli/blob/latest/CHANGELOG.md#v850-2022-02-10
# See: https://github.com/npm/cli/issues/2546
#
ARG PROJECT_ID

FROM gcr.io/${PROJECT_ID}/node:${NODE_TAG}

ARG CLOUD_SDK_URL='https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-410.0.0-linux-x86_64.tar.gz'
ARG GCLOUD_TAG=410.0.0
ARG NODE_TAG=16.14.0-buster

ENV NODE_PATH=/usr/local/lib/node_modules

# firebase and gcloud install
RUN mkdir -p /opt && cd /opt                                               && \
    curl -so gcp-sdk.tgz --url ${CLOUD_SDK_URL}                            && \
    tar xfz gcp-sdk.tgz                                                    && \
    cd google-cloud-sdk                                                    && \
    ./install.sh -q --path-update true                                     && \
    cd /root                                                               && \
    /opt/google-cloud-sdk/bin/gcloud components update --quiet             && \
    /opt/google-cloud-sdk/bin/gcloud components install alpha beta --quiet && \
    rm /opt/gcp-sdk.tgz

# gcloud setup
RUN ln -s /opt/google-cloud-sdk/bin/gcloud /usr/local/bin

# versions and limits
RUN . /usr/local/lib/utils.bash             && \
    print_versions node npm gcloud && \
    echo '~===~ node limits ~===~'          && \
    sudo -u node sh -c 'ulimit -a'          && \
    echo '~===~ -*-*-*-*-*- ~===~'

ENTRYPOINT [ "/usr/local/bin/gcloud" ]

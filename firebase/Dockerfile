FROM node:14-buster

ARG CLOUD_SDK_URL='https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-367.0.0-linux-x86_64.tar.gz'
ARG NPM_E11='npm.pkg.github.com/engineering11'
ARG NPM_TOKEN

# os packages
RUN apt-get update       && \
    apt-get install -y      \
            gettext-base    \
            jq              \
            netcat          \
            sudo

# public node packages
RUN npm install --no-progress --global    \
        @angular/cli                      \
        @angular-devkit/schematics-cli    \
        ajv                               \
        api-spec-converter                \
        jsonpath                          \
        @nestjs/cli                       \
        rollbar-cli                       \
        yaml                           && \
    yarn global add typescript

# private node packages
RUN npm config set @engineering11:registry=https://${NPM_E11}/ && \
    npm config set //${NPM_E11}/:_authToken=${NPM_TOKEN}       && \
    npm install --no-progress --global                            \
        @e11community/token-exporter                              \
        @engineering11/ecli                                       \
        @engineering11/sdk-schematics                          && \
    rm -f ~/.npmrc

# firebase and gcloud install
RUN mkdir -p /opt && cd /opt                                               && \
    curl -Lso firebase 'https://firebase.tools/bin/linux/latest'           && \
    install -m 755 ./firebase /usr/bin/firebase                            && \
    curl -so gcp-sdk.tgz --url ${CLOUD_SDK_URL}                            && \
    tar xfz gcp-sdk.tgz                                                    && \
    cd google-cloud-sdk                                                    && \
    ./install.sh -q --path-update true                                     && \
    cd /root                                                               && \
    /opt/google-cloud-sdk/bin/gcloud components update --quiet             && \
    /opt/google-cloud-sdk/bin/gcloud components install alpha beta --quiet && \
    rm /opt/gcp-sdk.tgz

# firebase and gcloud setup
ADD firebase.bash /usr/bin/
RUN chmod +x /usr/bin/firebase.bash                        && \
    ln -s /opt/google-cloud-sdk/bin/gcloud /usr/local/bin

# versions and limits
ADD utils.bash /usr/local/lib/
RUN . /usr/local/lib/utils.bash             && \
    print_versions node npm firebase gcloud && \
    echo '~===~ node limits ~===~'          && \
    sudo -u node sh -c 'ulimit -a'          && \
    echo '~===~ -*-*-*-*-*- ~===~'

ENTRYPOINT [ "/usr/bin/firebase.bash" ]

FROM node:20.9.0-buster

ARG CLOUD_SDK_URL='https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-453.0.0-linux-x86_64.tar.gz'
ARG FIREBASE_URL='https://firebase.tools/bin/linux/v12.8.0'
ARG NPM_E11='npm.pkg.github.com/engineering11'
ARG NPM_TOKEN

ENV NODE_PATH=/usr/local/lib/node_modules

# os packages
RUN apt-get update       && \
    apt-get install -y      \
            gettext-base    \
            jq              \
            netcat          \
            sudo            \
            zip

# public node packages
RUN npm install --no-progress --global --legacy-peer-deps=true \
        ajv@6.9.2                                              \
        @angular/cli                                           \
        @angular-devkit/schematics-cli                         \
        api-spec-converter                                     \
        google-auth-library                                    \
        @google-cloud/appengine-admin                          \
        @google-cloud/iap                                      \
        @google-cloud/resource-manager                         \
        gts@3.1.0                                              \
        husky                                                  \
        @nestjs/cli                                            \
        rollbar-cli                                            \
        yaml                                                && \
    yarn global add typescript

# private node packages
RUN npm config set @engineering11:registry=https://${NPM_E11}/ && \
    npm config set //${NPM_E11}/:_authToken=${NPM_TOKEN}       && \
    npm install --legacy-peer-deps=true --no-progress --global    \
        @e11community/token-exporter                              \
        @engineering11/ecli                                       \
        @engineering11/sdk-schematics                          && \
    rm -f ~/.npmrc

# firebase and gcloud install
RUN mkdir -p /opt && cd /opt                                               && \
    curl -Lso firebase --url ${FIREBASE_URL}                               && \
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

ADD firebase.bash /usr/bin
RUN chmod +x /usr/bin/firebase.bash

ENTRYPOINT [ "/usr/bin/firebase.bash" ]

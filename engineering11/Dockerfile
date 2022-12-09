#
# Highest version of node with the highest version of npm < 8.5.0
#
# See: https://nodejs.org/en/download/releases/
# See: https://github.com/npm/cli/blob/latest/CHANGELOG.md#v850-2022-02-10
# See: https://github.com/npm/cli/issues/2546
#

ARG FIREBASE_TAG=11.8.0
ARG PROJECT_ID

FROM gcr.io/${PROJECT_ID}/firebase:${FIREBASE_TAG}

ARG GCLOUD_TAG=410.0.0
ARG NODE_TAG=16.14.0-buster
ARG NPM_E11='npm.pkg.github.com/engineering11'
ARG NPM_TOKEN

ENV NODE_PATH=/usr/local/lib/node_modules

# private node packages
RUN npm config set @engineering11:registry=https://${NPM_E11}/ && \
    npm config set //${NPM_E11}/:_authToken=${NPM_TOKEN}       && \
    npm install --legacy-peer-deps=true --no-progress --global    \
        @e11community/token-exporter                              \
        @engineering11/ecli                                       \
        @engineering11/sdk-schematics                          && \
    rm -f ~/.npmrc

RUN . /usr/local/lib/utils.bash             && \
    print_versions node npm firebase gcloud && \
    echo '~===~ node limits ~===~'          && \
    sudo -u node sh -c 'ulimit -a'          && \
    echo '~===~ -*-*-*-*-*- ~===~'

ENTRYPOINT [ "/usr/bin/firebase.bash" ]

#
# Highest version of node with the highest version of npm < 8.5.0
#
# See: https://nodejs.org/en/download/releases/
# See: https://github.com/npm/cli/blob/latest/CHANGELOG.md#v850-2022-02-10
# See: https://github.com/npm/cli/issues/2546
#
ARG NODE_TAG=16.14.0-buster

FROM node:${NODE_TAG}

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
        @google-cloud/api-gateway                              \
        @google-cloud/appengine-admin                          \
        @google-cloud/bigquery                                 \
        @google-cloud/billing                                  \
        @google-cloud/cloudbuild                               \
        @google-cloud/compute                                  \
        @google-cloud/datastore                                \
        @google-cloud/eventarc                                 \
        @google-cloud/firestore                                \
        @google-cloud/functions                                \
        @google-cloud/iap                                      \
        @google-cloud/logging-winston                          \
        @google-cloud/os-config                                \
        @google-cloud/pubsub                                   \
        @google-cloud/resource-manager                         \
        @google-cloud/run                                      \
        @google-cloud/secret-manager                           \
        @google-cloud/storage                                  \
        @google-cloud/talent                                   \
        @google-cloud/tasks                                    \
        @google-cloud/vpc-access                               \
        gts@3.1.0                                              \
        husky                                                  \
        @nestjs/cli                                            \
        rollbar-cli                                            \
        yaml                                                && \
    yarn global add typescript

# versions and limits
ADD utils.bash /usr/local/lib/
RUN . /usr/local/lib/utils.bash             && \
    print_versions node npm                 && \
    echo '~===~ node limits ~===~'          && \
    sudo -u node sh -c 'ulimit -a'          && \
    echo '~===~ -*-*-*-*-*- ~===~'

ENTRYPOINT [ "/usr/bin/node" ]

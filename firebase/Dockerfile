#
# Highest version of node with the highest version of npm < 8.5.0
#
# See: https://nodejs.org/en/download/releases/
# See: https://github.com/npm/cli/blob/latest/CHANGELOG.md#v850-2022-02-10
# See: https://github.com/npm/cli/issues/2546
#

ARG GCLOUD_TAG=410.0.0
ARG PROJECT_ID

FROM gcr.io/${PROJECT_ID}/gcloud:${GCLOUD_TAG}

ARG FIREBASE_TAG=11.8.0

ENV NODE_PATH=/usr/local/lib/node_modules

# firebase install
RUN mkdir -p /opt && cd /opt && \                             
    curl -Lso firebase --url https://firebase.tools/bin/linux/v${FIREBASE_TAG} && \
    stat firebase && \
    install -m 755 ./firebase /usr/bin/firebase

# firebase setup
ADD firebase.bash /usr/bin/
RUN chmod +x /usr/bin/firebase.bash

# versions and limits
RUN . /usr/local/lib/utils.bash             && \
    print_versions node npm firebase gcloud && \
    echo '~===~ node limits ~===~'          && \
    sudo -u node sh -c 'ulimit -a'          && \
    echo '~===~ -*-*-*-*-*- ~===~'

ADD firebase.bash /usr/bin
RUN chmod +x /usr/bin/firebase.bash

ENTRYPOINT [ "/usr/bin/firebase.bash" ]

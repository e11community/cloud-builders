FROM node:14

RUN npm_config_user=root npm i -g firebase-tools @angular/cli && \
    yarn global add typescript

RUN curl -so gc-sdk.tgz 'https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-343.0.0-linux-x86_64.tar.gz' && \
    tar xfz gc-sdk.tgz && \
    cd google-cloud-sdk && \
    ./install.sh -q --path-update true


ADD firebase.bash /usr/bin

RUN yarn -v && node -v && npm -v && ng v && /google-cloud-sdk/bin/gcloud -v && firebase --version && tsc -v

RUN chmod +x /usr/bin/firebase.bash

ENTRYPOINT [ "/usr/bin/firebase.bash" ]

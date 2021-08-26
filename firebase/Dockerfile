FROM node:14-buster

ARG NPM_TOKEN

# os packages
RUN apt-get update && apt-get install -y gettext-base sudo

# node packages
RUN npm config set @engineering11:registry=https://npm.pkg.github.com/engineering11/ && \
    npm config set //npm.pkg.github.com/engineering11/:_authToken=${NPM_TOKEN} && \
    npm install --no-progress --global \
      @e11community/token-exporter \
      @engineering11/sdk-schematics \
      @angular/cli \
      @angular-devkit/schematics-cli \
      firebase-tools \
      rollbar-cli && \
    rm -f ~/.npmrc

# ts
RUN yarn global add typescript

# gcloud install
RUN mkdir -p /opt && cd /opt && \
    curl -so gcp-sdk.tgz 'https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-343.0.0-linux-x86_64.tar.gz' && \
    tar xfz gcp-sdk.tgz && \
    cd google-cloud-sdk && \
    ./install.sh -q --path-update true && \
    cd - && rm gcp-sdk.tgz

# firebase and gcloud setup
ADD firebase.bash /usr/bin/
RUN chmod +x /usr/bin/firebase.bash && \
    ln -s /opt/google-cloud-sdk/bin/gcloud /usr/local/bin

# versions and limits
ADD utils.bash /usr/local/lib/
RUN . /usr/local/lib/utils.bash && \
    print_versions node npm firebase gcloud && \
    echo '~===~ node limits ~===~' && \
    sudo -u node sh -c 'ulimit -a' && \
    echo '~===~ -*-*-*-*-*- ~===~'

ENTRYPOINT [ "/usr/bin/firebase.bash" ]

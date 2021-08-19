FROM node:14-buster

# os packages
RUN apt-get update && apt-get install -y gettext-base sudo

# npm packages
RUN npm_config_user=root npm install --no-progress --global \
    @angular/cli \
    @e11community/token-exporter \
    firebase-tools \
    rollbar-cli && \
    yarn global add typescript

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
    echo '~===~===~' && \
    sudo -u node sh -c 'ulimit -a' && \
    echo '~===~===~'

ENTRYPOINT [ "/usr/bin/firebase.bash" ]

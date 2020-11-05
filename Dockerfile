FROM docker

LABEL tools="docker-image, gitlab-aws, aws, helm, helm-charts, docker, kubectl, sops, kubeval, ecr, bash, alpine, curl, git"
# version is kubectl version
LABEL version="1.17.9"
LABEL description="An Alpine based docker image contains a good combination of commenly used tools\
    to build, package as docker image, login and push to AWS ECR, AWS authentication and all Kuberentes staff. \
    tools included: Docker, AWS-CLI, Kubectl, Helm, Curl, Git, Bash."
LABEL maintainer="eng.ahmed.srour@gmail.com, 3856350+guitarrapc@users.noreply.github.com"

# https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
ENV AWS_CLI_VERSION="2.0.30" \
    GLIBC_VERSION="2.31-r0" \
    KUBECTL_VERSION="1.18.8" \
    KUBECTL_DATE="2020-09-18" \
    HELM_VERSION="3.4.0" \
    HELM_S3_VERSION="0.10.0" \
    KUBEVAL_VERSION="0.15.0" \
    DOCKERIZE_VERSION="0.6.1" \
    SOPS_VERSION="3.6.1"

RUN set -x && \
    apk --no-cache update && \
    apk --no-cache add curl binutils jq make bash ca-certificates groff less git openssh-client && \
    rm -rf /var/cache/apk/*

WORKDIR /tmp

# install glibc to alpine https://stackoverflow.com/questions/60298619/awscli-version-2-on-alpine-linux/61268529#61268529
RUN curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub && \
    curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
    apk add --no-cache glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk && \
    rm -rf /var/cache/apk/* && \
    rm ./glibc-${GLIBC_VERSION}.apk && \
    rm ./glibc-bin-${GLIBC_VERSION}.apk

RUN curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm ./awscliv2.zip && \
    rm -rf ./aws

WORKDIR /

RUN curl -sL https://github.com/jwilder/dockerize/releases/download/v$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz -o dockerize-alpine-linux-amd64.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64.tar.gz \
    && rm dockerize-alpine-linux-amd64.tar.gz

RUN curl -sL https://amazon-eks.s3-us-west-2.amazonaws.com/${KUBECTL_VERSION}/${KUBECTL_DATE}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

RUN curl -sL https://github.com/garethr/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz -o kubeval-linux-amd64.tar.gz \
    && tar -C /usr/local/bin -xzvf kubeval-linux-amd64.tar.gz \
    && rm kubeval-linux-amd64.tar.gz

RUN curl -sL https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux -o /usr/local/bin/sops \
    && chmod +x /usr/local/bin/sops

#ENV HELM_HOME=~/.helm
#RUN mkdir -p ~/.helm/plugins

#RUN git clone https://github.com/hypnoglow/helm-s3.git

# Install Helm
RUN curl -sL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm-linux-amd64.tar.gz \
    && tar -zxvf helm-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && rm helm-linux-amd64.tar.gz \
    && rm -rf linux-amd64

# Install Helm S3 Plugin
RUN helm plugin install https://github.com/hypnoglow/helm-s3.git --version ${HELM_S3_VERSION}

# Cleanup apt cache
RUN rm -rf /var/cache/apk/*

ENV LOG=file
#ENTRYPOINT ["docker --version"]
#CMD []

#CMD [jq -version]

#VOLUME /var/run/docker.sock:/var/run/docker.sock

WORKDIR /data

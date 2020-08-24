FROM docker

LABEL tools="docker-image, gitlab-aws, aws, helm, helm-charts, docker, gitlab, gitlab-ci, kubectl, s3, aws-iam-authenticator, ecr, bash, envsubst, alpine, curl, python3, pip3, git"
# version is kubectl version
LABEL version="1.17.9"
LABEL description="An Alpine based docker image contains a good combination of commenly used tools\
    to build, package as docker image, login and push to AWS ECR, AWS authentication and all Kuberentes staff. \
    tools included: Docker, AWS-CLI, Kubectl, Helm, Curl, Python, Envsubst, Python, Pip, Git, Bash, AWS-IAM-Auth."
LABEL maintainer="eng.ahmed.srour@gmail.com, 3856350+guitarrapc@users.noreply.github.com"

# https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
ENV AWS_CLI_VERSION="1.18.31" \
    ENVSUBST_VERSION="1.1.0" \
    AWS_IAM_AUTHENTICATOR_VERSION="1.17.9" \
    AWS_IAM_AUTHENTICATOR_DATE="2020-08-04" \
    KUBECTL_VERSION="1.17.9" \
    KUBECTL_DATE="2020-08-04" \
    HELM_VERSION="3.3.0" \
    HELM_S3_VERSION="0.9.2" \
    KUBEVAL_VERSION="0.15.0" \
    DOCKERIZE_VERSION="0.6.1" \
    SOPS_VERSION="3.6.0"

RUN set -x && \
    apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache
# additionally required by docker-compose:
# python3-dev libffi-dev openssl-dev gcc libc-dev make

RUN set -x && \
    apk --no-cache update && \
    apk --no-cache add curl jq make bash ca-certificates groff less git openssh-client && \
    pip3 install --upgrade awscli urllib3 && \
    pip3 --no-cache-dir install awscli==${AWS_CLI_VERSION} && \
    rm -rf /var/cache/apk/*

# omit docker-compose. don't need without dind, let's remove in this fork.
# RUN pip3 --no-cache-dir install docker-compose 

RUN curl -sL https://github.com/jwilder/dockerize/releases/download/v$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz -o dockerize-alpine-linux-amd64.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64.tar.gz \
    && rm dockerize-alpine-linux-amd64.tar.gz

RUN curl -sL https://github.com/a8m/envsubst/releases/download/v${ENVSUBST_VERSION}/envsubst-Linux-x86_64 -o /usr/local/bin/envsubst \
    && chmod +x /usr/local/bin/envsubst

RUN curl -sL https://amazon-eks.s3-us-west-2.amazonaws.com/${AWS_IAM_AUTHENTICATOR_VERSION}/${AWS_IAM_AUTHENTICATOR_DATE}/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator \
    && chmod +x /usr/local/bin/aws-iam-authenticator

RUN curl -sL https://amazon-eks.s3-us-west-2.amazonaws.com/${KUBECTL_VERSION}/${KUBECTL_DATE}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

RUN curl -sL https://github.com/garethr/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz -o kubeval-linux-amd64.tar.gz \
    && tar -C /usr/local/bin -xzvf kubeval-linux-amd64.tar.gz \
    && rm kubeval-linux-amd64.tar.gz

RUN curl -sL https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux -o /usr/local/bin/sops \
    && chmod +x /usr/local/bin/sops

# Install GIT
RUN apk add --no-cache git

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

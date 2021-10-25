# # Update versions as needed.
# FROM lachlanevenson/k8s-helm:v3.7.0
# FROM lachlanevenson/k8s-kubectl:v1.20.11

# # THIS DOES THE TRICK FOR INSTALLING AWS CLI V2

# COPY --from=0 /usr/local/bin/helm /usr/local/bin/helm
# COPY --from=1 /usr/local/bin/kubectl /usr/local/bin/kubectl

#-----
FROM alpine:3.11

ENV GLIBC_VER=2.31-r0

# install glibc compatibility for alpine
RUN apk --no-cache add \
        binutils \
        curl \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-i18n-${GLIBC_VER}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk \
        glibc-i18n-${GLIBC_VER}.apk \
    && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install \
    && rm -rf \
        awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples \
        glibc-*.apk \
    && apk add --no-cache jq bash \
    && apk --no-cache del \
        binutils \
    && rm -rf /var/cache/apk/*

# INSTALL HELM

ENV HELM_VER=v3.7.1

RUN curl -sL https://get.helm.sh/helm-${HELM_VER}-linux-amd64.tar.gz -o helm.tar.gz \
    && tar -xvf helm.tar.gz \
    && mv linux-amd64/helm /usr/bin/ \
    && chmod +x /usr/bin/helm

# INSTALL KUBECTL

ENV KUBECTL_VER=v1.20.11

RUN curl -sL https://dl.k8s.io/release/${KUBECTL_VER}/bin/linux/amd64/kubectl -o kubectl \
    && mv kubectl /usr/bin/ \
    && chmod +x /usr/bin/kubectl


# ADD PYTHON AND SOME PIP PACKAGES
RUN apk add -U --no-cache python3 ca-certificates py3-pip \
    && pip3 install --no-cache-dir --upgrade pip \
    && pip3 --no-cache-dir install yq


# JENKINS SWARM INSTALLATION
ENV SWARM_CLIENT_VERSION="3.28" 

RUN adduser -G root -D jenkins && \
    apk --update --no-cache add openjdk8-jre git git-lfs openssh ca-certificates openssl && \
    curl -sL https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_CLIENT_VERSION}/swarm-client-${SWARM_CLIENT_VERSION}.jar -o /home/jenkins/jenkins-swarm.jar 


COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
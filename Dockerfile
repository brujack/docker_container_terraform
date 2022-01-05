FROM ubuntu:focal

ARG TERRAFORM_VER="1.1.2"
ARG TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip"
ARG CHRUBY_VER="0.3.9"
ARG CHRUBY_URL="https://github.com/postmodern/chruby/archive/v${CHRUBY_VER}.tar.gz"
ARG RUBY_VER="3.0.2"

LABEL maintainer="brujack"
LABEL terraform_version=$TERRAFORM_VER

ENV DEBIAN_FRONTEND=noninteractive
ENV TERRAFORM_VERSION=${TERRAFORM_VER}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common \
    && apt-get update \
    && add-apt-repository ppa:git-core/ppa -y \
    && apt-get install -y --no-install-recommends apt-utils curl git make tar unzip wget \
    && apt-get upgrade -y \
    && mkdir -p downloads \
    && wget -q -O downloads/terraform_${TERRAFORM_VER}_linux_amd64.zip ${TERRAFORM_URL} \
    && unzip 'downloads/*.zip' -d /usr/local/bin \
    && wget -q -O downloads/chruby-${CHRUBY_VER}.tar.gz ${CHRUBY_URL} \
    && tar -xzvf downloads/chruby-${CHRUBY_VER}.tar.gz -C downloads/ \
    && cd downloads/chruby-${CHRUBY_VER}/ \
    && make install \
    && ruby-install ruby ${RUBY_VER} \
    && gem install terraspace \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* downloads

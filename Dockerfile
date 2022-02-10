FROM ubuntu:focal

ARG TERRAFORM_VER="1.1.5"
ARG TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip"
ARG RUBY_INSTALL_VER="0.8.3"
ARG RUBY_INSTALL_URL="https://github.com/postmodern/ruby-install/archive/v${RUBY_INSTALL_VER}.tar.gz"
ARG RUBY_VER="3.0.2"
ARG TFLINT_VER="v0.34.1"
ARG TFLINT_URL="https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VER}/tflint_linux_amd64.zip"
ARG TFSEC_VER="v1.1.3"
ARG TFSEC_URL="https://github.com/aquasecurity/tfsec/releases/download/${TFSEC_VER}/tfsec-linux-amd64"
ARG TERRASPACE_VER="1.1.1"

LABEL maintainer="brujack"
LABEL terraform_version=$TERRAFORM_VER

ENV DEBIAN_FRONTEND=noninteractive
ENV TERRAFORM_VERSION=${TERRAFORM_VER}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils shellcheck software-properties-common \
    && apt-get update \
    && add-apt-repository ppa:git-core/ppa -y \
    && apt-get install -y --no-install-recommends apt-utils curl git make tar unzip wget \
    && apt-get upgrade -y \
    && sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin \
    && mkdir -p downloads \
    && wget -q -O downloads/terraform_${TERRAFORM_VER}_linux_amd64.zip ${TERRAFORM_URL} \
    && unzip downloads/terraform_${TERRAFORM_VER}_linux_amd64.zip -d /usr/local/bin \
    && wget -q -O downloads/tflint_linux_amd64.zip ${TFLINT_URL} \
    && unzip downloads/tflint_linux_amd64.zip -d /usr/local/bin \
    && chmod 755 /usr/local/bin/tflint \
    && wget -q -O downloads/tfsec-linux-amd64 ${TFSEC_URL} \
    && mv downloads/tfsec-linux-amd64 /usr/local/bin/tfsec \
    && chmod 755 /usr/local/bin/tfsec \
    && wget -q -O downloads/ruby-install-${RUBY_INSTALL_VER}.tar.gz ${RUBY_INSTALL_URL} \
    && tar -xzvf downloads/ruby-install-${RUBY_INSTALL_VER}.tar.gz -C downloads/
WORKDIR /downloads/ruby-install-${RUBY_INSTALL_VER}/
RUN make install \
    && ruby-install ruby ${RUBY_VER} \
    && ln -s /opt/rubies/ruby-${RUBY_VER}/bin/ruby /usr/local/bin/ruby \
    && ln -s /opt/rubies/ruby-${RUBY_VER}/bin/gem /usr/local/bin/gem \
    && gem install terraspace:${TERRASPACE_VER} \
    && ln -s /opt/rubies/ruby-${RUBY_VER}/lib/ruby/gems/3.0.0/terraspace /usr/local/bin/terraspace \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* downloads

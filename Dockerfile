# syntax=docker/dockerfile:1
# https://docs.docker.com/reference/dockerfile/

# SPDX-License-Identifier: BSD-3-Clause

ARG PMD_VERSION
ARG JAVA_VERSION=21

# https://hub.docker.com/_/eclipse-temurin
FROM eclipse-temurin:${JAVA_VERSION}-alpine

# Workaround for https://github.com/pmd/pmd/issues/5705
# PMD_HOME -> DOCKER_PMD_HOME
ENV DOCKER_PMD_HOME=/opt/pmd
ENV PATH=${DOCKER_PMD_HOME}/bin:${PATH}

# bring global args into scope
ARG PMD_VERSION

RUN set -eux; \
    apk add --no-cache \
        # currently needed to run PMD, until https://github.com/pmd/pmd/pull/5623
        bash \
    ; \
    rm -rf /var/cache/apk/*

RUN set -eux; \
    wget -O /pmd-dist-${PMD_VERSION}-bin.zip https://github.com/pmd/pmd/releases/download/pmd_releases%2F${PMD_VERSION}/pmd-dist-${PMD_VERSION}-bin.zip; \
    wget -O /pmd-dist-${PMD_VERSION}-bin.zip.asc https://github.com/pmd/pmd/releases/download/pmd_releases%2F${PMD_VERSION}/pmd-dist-${PMD_VERSION}-bin.zip.asc || true; \
    if [ -e /pmd-dist-${PMD_VERSION}-bin.zip.asc ]; then \
        export GNUPGHOME="$(mktemp -d)"; \
        # gpg: key A0B5CA1A4E086838: public key "PMD Release Signing Key <releases@pmd-code.org>" imported
        # See https://docs.pmd-code.org/latest/pmd_userdocs_signed_releases.html
        gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 1E046C19ED2873D8C08AF7B8A0632691B78E3422; \
        gpg --batch --verify /pmd-dist-${PMD_VERSION}-bin.zip.asc /pmd-dist-${PMD_VERSION}-bin.zip; \
        rm -rf "${GNUPGHOME}" /pmd-dist-${PMD_VERSION}-bin.zip.asc; \
    else \
        echo "WARNING: can't verify binary with gpg"; \
    fi; \
    unzip -d / /pmd-dist-${PMD_VERSION}-bin.zip; \
    rm /pmd-dist-${PMD_VERSION}-bin.zip; \
    mv /pmd-bin-${PMD_VERSION} ${DOCKER_PMD_HOME};


RUN mkdir /src \
    mkdir /custom-pmd-libs
ENV CLASSPATH="/custom-pmd-libs/*"
WORKDIR /src

RUN set -eux; \
    echo "Verifying install ..."; \
    echo "pmd --version"; pmd --version; \
    echo "Complete."

ENTRYPOINT ["pmd"]

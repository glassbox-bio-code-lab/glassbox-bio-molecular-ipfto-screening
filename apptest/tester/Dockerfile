ARG GOLANG_BUILD_IMAGE=golang:1.25.11
ARG KUBECTL_VERSION=v1.34.3
ARG MP_SERVICE_NAME=services/glassbox-bio-molecular-ip-fto-screening.endpoints.glassbox-bio-public.cloud.goog

FROM ${GOLANG_BUILD_IMAGE} AS kubectl-builder
ARG KUBECTL_VERSION
WORKDIR /src
RUN curl -fsSLo kubernetes-src.tar.gz "https://github.com/kubernetes/kubernetes/archive/refs/tags/${KUBECTL_VERSION}.tar.gz" \
    && tar -xzf kubernetes-src.tar.gz --strip-components=1 \
    && /usr/local/go/bin/go mod edit -require=golang.org/x/net@v0.38.0 -require=golang.org/x/oauth2@v0.27.0 -require=github.com/moby/spdystream@v0.5.1 \
    && /usr/local/go/bin/go work vendor \
    && PATH=/usr/local/go/bin:$PATH make kubectl KUBE_VERBOSE=0 \
    && install -D _output/local/go/bin/kubectl /out/kubectl

FROM python:3.12-slim-bookworm

ARG MP_SERVICE_NAME
LABEL com.googleapis.cloudmarketplace.product.service.name=${MP_SERVICE_NAME}

RUN set -eux; \
    apt-get update; \
    apt-get -y dist-upgrade; \
    apt-get install -y --no-install-recommends ca-certificates bash jq curl libgnutls30 openssl; \
    gnutls_version="$(dpkg-query -W -f='${Version}' libgnutls30)"; \
    dpkg --compare-versions "${gnutls_version}" ge 3.7.9-2+deb12u7; \
    openssl_version="$(dpkg-query -W -f='${Version}' openssl)"; \
    dpkg --compare-versions "${openssl_version}" ge 3.0.20-1~deb12u2; \
    libssl_version="$(dpkg-query -W -f='${Version}' libssl3)"; \
    dpkg --compare-versions "${libssl_version}" ge 3.0.20-1~deb12u2; \
    dpkg --force-depends --force-remove-essential --purge perl-base; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*

COPY --from=kubectl-builder /out/kubectl /usr/bin/kubectl
RUN chmod 0755 /usr/bin/kubectl

COPY tests/basic-suite.yaml /tests/basic-suite.yaml
COPY run_tests.py /run_tests.py

RUN python -m pip install --no-cache-dir --upgrade "pip>=26" "setuptools>=78.1.1,<82" "wheel>=0.46.3" pyyaml \
    && rm -f /usr/local/lib/python*/ensurepip/_bundled/pip-*.whl \
          /usr/local/lib/python*/ensurepip/_bundled/setuptools-*.whl

WORKDIR /
ENTRYPOINT ["python", "/run_tests.py"]

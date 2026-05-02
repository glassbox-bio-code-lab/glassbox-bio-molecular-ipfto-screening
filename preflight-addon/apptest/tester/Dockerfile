ARG GOLANG_BUILD_IMAGE=golang:1.25.8
ARG KUBECTL_VERSION=v1.31.14
ARG MP_SERVICE_NAME=services/glassbox-bio-molecular-ip-fto-screening.endpoints.glassbox-bio-public.cloud.goog

FROM ${GOLANG_BUILD_IMAGE} AS kubectl-builder
ARG KUBECTL_VERSION
WORKDIR /src
RUN curl -fsSLo kubernetes-src.tar.gz "https://github.com/kubernetes/kubernetes/archive/refs/tags/${KUBECTL_VERSION}.tar.gz" \
    && tar -xzf kubernetes-src.tar.gz --strip-components=1 \
    && /usr/local/go/bin/go mod edit -require=golang.org/x/net@v0.38.0 -require=golang.org/x/oauth2@v0.27.0 \
    && /usr/local/go/bin/go work vendor \
    && PATH=/usr/local/go/bin:$PATH make kubectl KUBE_VERBOSE=0 \
    && install -D _output/local/go/bin/kubectl /out/kubectl

FROM python:3.12-slim

ARG MP_SERVICE_NAME
LABEL com.googleapis.cloudmarketplace.product.service.name=${MP_SERVICE_NAME}

RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends ca-certificates bash jq curl \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY --from=kubectl-builder /out/kubectl /usr/bin/kubectl
RUN chmod 0755 /usr/bin/kubectl

COPY tests/basic-suite.yaml /tests/basic-suite.yaml
COPY run_tests.py /run_tests.py

RUN python -m pip install --no-cache-dir --upgrade "pip>=26" "setuptools>=78.1.1,<82" "wheel>=0.46.3" pyyaml \
    && rm -f /usr/local/lib/python*/ensurepip/_bundled/pip-*.whl \
          /usr/local/lib/python*/ensurepip/_bundled/setuptools-*.whl

WORKDIR /
ENTRYPOINT ["python", "/run_tests.py"]

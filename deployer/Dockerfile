ARG DEPLOYER_BASE_IMAGE=gcr.io/cloud-marketplace-tools/k8s/deployer_helm:0.12.12
ARG GOLANG_BUILD_IMAGE=golang:1.25.10
ARG HELM_VERSION=v3.20.1
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

FROM ${GOLANG_BUILD_IMAGE} AS helm-builder
ARG HELM_VERSION
WORKDIR /src
RUN curl -fsSLo helm-src.tar.gz "https://github.com/helm/helm/archive/refs/tags/${HELM_VERSION}.tar.gz" \
    && tar -xzf helm-src.tar.gz --strip-components=1 \
    && /usr/local/go/bin/go get \
      golang.org/x/crypto@v0.46.0 \
      golang.org/x/net@v0.48.0 \
      golang.org/x/oauth2@v0.34.0 \
      google.golang.org/grpc@v1.79.3 \
      google.golang.org/protobuf@v1.36.10 \
    && /usr/local/go/bin/go mod download \
    && CGO_ENABLED=0 /usr/local/go/bin/go build -trimpath -ldflags="-s -w" -o /out/helm ./cmd/helm

FROM ${DEPLOYER_BASE_IMAGE}
ARG MP_SERVICE_NAME
LABEL com.googleapis.cloudmarketplace.product.service.name=${MP_SERVICE_NAME}

RUN apt-get update \
    && apt-get dist-upgrade -y \
    && python3 -m pip install --no-cache-dir --upgrade "pip>=24.0" \
    && python3 -m pip install --no-cache-dir --upgrade \
      "pyOpenSSL>=26,<27" \
      "cryptography>=46.0.7,<47" \
    && apt-get purge -y python3-pip wget gnupg2 \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY --from=kubectl-builder /out/kubectl /opt/kubectl/1.34/kubectl
COPY --from=helm-builder /out/helm /usr/bin/helm

RUN rm -rf /opt/kubectl/1.30 /opt/kubectl/1.31 /opt/kubectl/default \
    && chmod 0755 /opt/kubectl/1.34/kubectl /usr/bin/helm \
    && ln -snf /opt/kubectl/1.34 /opt/kubectl/default

RUN mkdir -p /data/chart /data-test/chart

COPY manifest/chart/ /tmp/marketplace-main/chart/
RUN tar -czf /data/chart/chart-bundle.tar.gz -C /tmp/marketplace-main chart \
    && rm -rf /tmp/marketplace-main
COPY schema.yaml /data/schema.yaml

COPY apptest/deployer/manifest/chart/values.yaml /tmp/marketplace-test/chart/values.yaml
RUN tar -czf /data-test/chart/chart-bundle.tar.gz -C /tmp/marketplace-test chart \
    && rm -rf /tmp/marketplace-test
COPY apptest/deployer/schema.yaml /data-test/schema.yaml
COPY deployer/marketplace-debug-deploy.sh /usr/local/bin/marketplace-debug-deploy.sh
COPY deployer/deploy_with_tests.sh /bin/deploy_with_tests.sh
RUN chmod 0755 /usr/local/bin/marketplace-debug-deploy.sh /bin/deploy_with_tests.sh

ENV SCHEMA=/data/schema.yaml
ENV WAIT_FOR_READY_TIMEOUT=1800
ENV TESTER_TIMEOUT=1800

ENTRYPOINT ["/usr/local/bin/marketplace-debug-deploy.sh"]

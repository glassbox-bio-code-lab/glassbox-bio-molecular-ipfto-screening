SHELL := /bin/bash

ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DOCKER ?= docker
HELM ?= helm
PYTHON ?= python3

VERSION ?= 1.0.0
PRODUCT_REPO ?= us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening
PUBLIC_REPO ?= $(PRODUCT_REPO)/glassbox-ipfto
DEPLOYER_IMAGE ?= $(PRODUCT_REPO)/deployer:$(VERSION)
TESTER_IMAGE ?= $(PUBLIC_REPO)/tester:$(VERSION)
MP_SERVICE_NAME ?= services/glassbox-bio-molecular-ip-fto-screening.endpoints.glassbox-bio-public.cloud.goog

.PHONY: help lint template template-apptest check-tester-python build-deployer build-tester build-marketplace-images push-marketplace-images preflight-lint preflight-template preflight-template-apptest preflight-check-tester-python preflight-build-marketplace-images preflight-push-marketplace-images validate-all

help:
	@echo "IP/FTO Marketplace GKE bundle"
	@echo ""
	@echo "Validation:"
	@echo "  make lint"
	@echo "  make template"
	@echo "  make template-apptest"
	@echo "  make check-tester-python"
	@echo ""
	@echo "Images:"
	@echo "  make build-deployer"
	@echo "  make build-tester"
	@echo "  make build-marketplace-images"
	@echo "  make push-marketplace-images"
	@echo "  make validate-all"
	@echo ""
	@echo "Nested Preflight add-on integration:"
	@echo "  make preflight-lint"
	@echo "  make preflight-template"
	@echo "  make preflight-template-apptest"
	@echo "  make preflight-build-marketplace-images"
	@echo "  make preflight-push-marketplace-images"
	@echo ""
	@echo "Defaults:"
	@echo "  DEPLOYER_IMAGE=$(DEPLOYER_IMAGE)"
	@echo "  TESTER_IMAGE=$(TESTER_IMAGE)"

lint:
	@"$(HELM)" lint "$(ROOT_DIR)/manifest/chart"

template:
	@"$(HELM)" template glassbox-ipfto "$(ROOT_DIR)/manifest/chart" \
		--set job.enabled=false >/dev/null

template-apptest:
	@"$(HELM)" template glassbox-ipfto-test "$(ROOT_DIR)/manifest/chart" \
		-f "$(ROOT_DIR)/apptest/deployer/manifest/chart/values.yaml" >/dev/null

check-tester-python:
	@"$(PYTHON)" -m py_compile "$(ROOT_DIR)/apptest/tester/run_tests.py"

build-deployer:
	@"$(DOCKER)" build \
		-f "$(ROOT_DIR)/deployer/Dockerfile" \
		--build-arg MP_SERVICE_NAME="$(MP_SERVICE_NAME)" \
		-t "$(DEPLOYER_IMAGE)" \
		"$(ROOT_DIR)"

build-tester:
	@"$(DOCKER)" build \
		-f "$(ROOT_DIR)/apptest/tester/Dockerfile" \
		--build-arg MP_SERVICE_NAME="$(MP_SERVICE_NAME)" \
		-t "$(TESTER_IMAGE)" \
		"$(ROOT_DIR)/apptest/tester"

build-marketplace-images: build-deployer build-tester

push-marketplace-images:
	@"$(DOCKER)" push "$(DEPLOYER_IMAGE)"
	@"$(DOCKER)" push "$(TESTER_IMAGE)"

preflight-lint:
	@$(MAKE) -C "$(ROOT_DIR)/preflight-addon" lint

preflight-template:
	@$(MAKE) -C "$(ROOT_DIR)/preflight-addon" template

preflight-template-apptest:
	@$(MAKE) -C "$(ROOT_DIR)/preflight-addon" template-apptest

preflight-check-tester-python:
	@$(MAKE) -C "$(ROOT_DIR)/preflight-addon" check-tester-python

preflight-build-marketplace-images:
	@$(MAKE) -C "$(ROOT_DIR)/preflight-addon" build-marketplace-images

preflight-push-marketplace-images:
	@$(MAKE) -C "$(ROOT_DIR)/preflight-addon" push-marketplace-images

validate-all: lint template template-apptest check-tester-python preflight-lint preflight-template preflight-template-apptest preflight-check-tester-python

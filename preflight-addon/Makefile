SHELL := /bin/bash

ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DOCKER ?= docker
HELM ?= helm
PYTHON ?= python3

VERSION ?= 1.0.0
PUBLIC_REPO ?= us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/glassbox-ipfto
DEPLOYER_IMAGE ?= $(PUBLIC_REPO)/preflight-addon-deployer:$(VERSION)
TESTER_IMAGE ?= $(PUBLIC_REPO)/preflight-addon-tester:$(VERSION)
MP_SERVICE_NAME ?= services/glassbox-bio-molecular-ip-fto-screening.endpoints.glassbox-bio-public.cloud.goog

.PHONY: help lint template template-apptest check-tester-python build-deployer build-tester build-marketplace-images push-marketplace-images

help:
	@echo "IP/FTO Preflight add-on Marketplace bundle"
	@echo "  make lint"
	@echo "  make template"
	@echo "  make template-apptest"
	@echo "  make build-marketplace-images"
	@echo "  make push-marketplace-images"

lint:
	@"$(HELM)" lint "$(ROOT_DIR)/chart/ipfto-addon"

template:
	@"$(HELM)" template glassbox-ipfto-addon "$(ROOT_DIR)/chart/ipfto-addon" >/dev/null

template-apptest:
	@"$(HELM)" template glassbox-ipfto-addon-test "$(ROOT_DIR)/chart/ipfto-addon" \
		-f "$(ROOT_DIR)/apptest/deployer/ipfto-addon/values.yaml" >/dev/null

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

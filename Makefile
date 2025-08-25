DRAWIO_DESKTOP_VERSION = 1.47.0

IMAGE_NAME ?= drawio-desktop-headless
DOCKERHUB_IMAGE ?= fixl/$(IMAGE_NAME)
GITHUB_IMAGE ?= ghcr.io/fixl/docker-$(IMAGE_NAME)

BUILD_DATE = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

COMMIT_SHA ?= $(shell git rev-parse --short HEAD)
PROJECT_URL ?= $(shell git config --get remote.origin.url)
RUN_URL ?= local

TAG = $(DRAWIO_DESKTOP_VERSION)

EXTRACTED_FILE = extracted.tar
DOCKER_BUILDKIT = 1

TRIVY_COMMAND = docker compose run --rm trivy
ANYBADGE_COMMAND = docker compose run --rm anybadge
BINFMT_COMMAND = docker compose run --rm binfmt

DRAWIO_RUN_COMMAND = docker compose run --rm drawio

# Computed
PATCH = $(DRAWIO_DESKTOP_VERSION)
GITHUB_IMAGE_LATEST = $(GITHUB_IMAGE)
GITHUB_IMAGE_PATCH = $(GITHUB_IMAGE):$(PATCH)

DOCKERHUB_IMAGE_LATEST = $(DOCKERHUB_IMAGE)
DOCKERHUB_IMAGE_PATCH = $(DOCKERHUB_IMAGE):$(PATCH)

# Export variables for child processes
.EXPORT_ALL_VARIABLES:

/proc/sys/fs/binfmt_misc/qemu-aarch64:
	$(BINFMT_COMMAND) --install arm64
	-docker buildx create --use --name drawio

build:
	docker buildx build \
		--platform linux/amd64 \
		--progress=plain \
		--pull \
		--load \
		--build-arg DRAWIO_DESKTOP_VERSION=$(DRAWIO_DESKTOP_VERSION) \
		--label "org.opencontainers.image.title=$(IMAGE_NAME)" \
		--label "org.opencontainers.image.url=https://github.com/rlespinasse/docker-drawio-desktop-headless" \
		--label "org.opencontainers.image.authors=@fixl" \
		--label "org.opencontainers.image.version=$(DRAWIO_DESKTOP_VERSION)" \
		--label "org.opencontainers.image.created=$(BUILD_DATE)" \
		--label "org.opencontainers.image.source=$(PROJECT_URL)" \
		--label "org.opencontainers.image.revision=$(COMMIT_SHA)" \
		--label "info.fixl.github.run-url=$(RUN_URL)" \
		--tag $(IMAGE_NAME) \
		--tag $(GITHUB_IMAGE_LATEST) \
		--tag $(GITHUB_IMAGE_PATCH) \
		--tag $(DOCKERHUB_IMAGE_LATEST) \
		--tag $(DOCKERHUB_IMAGE_PATCH) \
		.

publish: /proc/sys/fs/binfmt_misc/qemu-aarch64
	docker buildx build \
		--platform linux/arm64,linux/amd64 \
		--progress=plain \
		--pull \
		--push \
		--build-arg DRAWIO_DESKTOP_VERSION=$(DRAWIO_DESKTOP_VERSION) \
		--label "org.opencontainers.image.title=$(IMAGE_NAME)" \
		--label "org.opencontainers.image.url=https://github.com/rlespinasse/docker-drawio-desktop-headless" \
		--label "org.opencontainers.image.authors=@fixl" \
		--label "org.opencontainers.image.version=$(DRAWIO_DESKTOP_VERSION)" \
		--label "org.opencontainers.image.created=$(BUILD_DATE)" \
		--label "org.opencontainers.image.source=$(PROJECT_URL)" \
		--label "org.opencontainers.image.revision=$(COMMIT_SHA)" \
		--label "info.fixl.github.run-url=$(RUN_URL)" \
		--tag $(GITHUB_IMAGE_LATEST) \
		--tag $(GITHUB_IMAGE_PATCH) \
		--tag $(DOCKERHUB_IMAGE_LATEST) \
		--tag $(DOCKERHUB_IMAGE_PATCH) \
		.

test:
	$(DRAWIO_RUN_COMMAND) ./test.sh
.PHONY: test

shell:
	$(DRAWIO_RUN_COMMAND) bash

scan: $(EXTRACTED_FILE)
	docker compose pull trivy

	$(TRIVY_COMMAND) trivy clean --scan-cache
	$(TRIVY_COMMAND) trivy image --input $(EXTRACTED_FILE) --exit-code 0 --no-progress --format sarif -o trivy-results.sarif $(IMAGE_NAME)
	$(TRIVY_COMMAND) trivy image --input $(EXTRACTED_FILE) --exit-code 1 --no-progress --ignore-unfixed --severity CRITICAL $(IMAGE_NAME)

$(EXTRACTED_FILE):
	docker save --output $(EXTRACTED_FILE) $(IMAGE_NAME)

badges:
	mkdir -p public
	$(ANYBADGE_COMMAND) docker-size $(DOCKERHUB_IMAGE_PATCH) public/size
	$(ANYBADGE_COMMAND) docker-version $(DOCKERHUB_IMAGE_PATCH) public/version

gitRelease:
	-git tag -d $(TAG)
	-git push origin :refs/tags/$(TAG)
	git tag $(TAG)
	git push origin $(TAG)
	git push

clean:
	$(TRIVY_COMMAND) rm -rf public/ *.tar *.sarif
	-$(BINFMT_COMMAND) --uninstall qemu-aarch64
	-docker buildx prune --force --all
	-docker buildx rm drawio
	-docker rmi $(IMAGE_NAME)
	-docker rmi $(GITHUB_IMAGE_LATEST)
	-docker rmi $(GITHUB_IMAGE_PATCH)
	-docker rmi $(DOCKERHUB_IMAGE_LATEST)
	-docker rmi $(DOCKERHUB_IMAGE_PATCH)

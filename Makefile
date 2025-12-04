# Versions
ERLANG_VERSION ?= 27
ELIXIR_VERSION ?= 1_18
VARIANT ?= bullseye

# GitHub Container Registry image
IMAGE_NAME = ghcr.io/kenpb/beam-devcontainers

# Tags
ERLANG_TAG = otp-$(ERLANG_VERSION)-$(VARIANT)
ELIXIR_TAG = otp-$(ERLANG_VERSION)-elixir-$(ELIXIR_VERSION)-$(VARIANT)

.PHONY: help build build-erlang build-elixir build-phoenix push push-erlang push-elixir push-phoenix clean

# Build all two images
build: build-erlang build-elixir build-phoenix

build-erlang:
	docker build \
		--build-arg VARIANT=$(VARIANT) \
		--build-arg ERLANG_VERSION=$(ERLANG_VERSION) \
		--build-arg USERNAME=vscode \
		--target erlang-only \
		-t $(IMAGE_NAME):$(ERLANG_TAG) .

build-elixir:
	docker build \
		--build-arg VARIANT=$(VARIANT) \
		--build-arg ERLANG_VERSION=$(ERLANG_VERSION) \
		--build-arg ELIXIR_VERSION=$(ELIXIR_VERSION) \
		--build-arg USERNAME=vscode \
		--target erlang-elixir \
		-t $(IMAGE_NAME):$(ELIXIR_TAG) .

# Push all two images
push: push-erlang push-elixir push-phoenix

push-erlang:
	docker push $(IMAGE_NAME):$(ERLANG_TAG)

push-elixir:
	docker push $(IMAGE_NAME):$(ELIXIR_TAG)

# Clean dangling images
clean:
	docker image prune -f

help:
	@echo "Available commands:"
	@echo "  build           - Build all two images (erlang, elixir)"
	@echo "  build-erlang    - Build Erlang-only image"
	@echo "  build-elixir    - Build Erlang + Elixir image"
	@echo "  push            - Push all two images to GHCR"
	@echo "  push-erlang     - Push Erlang-only image"
	@echo "  push-elixir     - Push Erlang + Elixir image"
	@echo "  clean           - Remove dangling images"
	@echo ""
	@echo "Configured versions:"
	@echo "  Erlang   : $(ERLANG_VERSION)"
	@echo "  Elixir   : $(ELIXIR_VERSION)"
	@echo "  Variant  : $(VARIANT)"

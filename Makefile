ERLANG_VERSION ?= `grep 'erlang_version' elixir_buildpack.config | cut -d '=' -f2`
ELIXIR_VERSION ?= `grep 'elixir_version' elixir_buildpack.config | cut -d '=' -f2`
ALPINE_VERSION ?= `grep 'alpine_version' elixir_buildpack.config | cut -d '=' -f2`

COMMAND ?= `grep 'web' Procfile | cut -d ':' -f2`
REVISION ?= `git rev-parse HEAD`
APP_NAME ?= "ex_gridhook"

.PHONY: app

test-image:
	DOCKER_BUILDKIT=1 docker build \
	  --build-arg MIX_ENV=test \
	  --build-arg ERLANG_VERSION=$(ERLANG_VERSION) \
	  --build-arg ELIXIR_VERSION=$(ELIXIR_VERSION) \
	  --build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		--build-arg REVISION=$(REVISION) \
	  --progress=plain \
	  -f Dockerfile \
		-t ${APP_NAME}:test \
	  .

prod-image:
	DOCKER_BUILDKIT=1 docker build \
	  --build-arg MIX_ENV=prod \
	  --build-arg ERLANG_VERSION=$(ERLANG_VERSION) \
	  --build-arg ELIXIR_VERSION=$(ELIXIR_VERSION) \
	  --build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		--build-arg REVISION=$(REVISION) \
	  --progress=plain \
	  -f Dockerfile \
		-t ${APP_NAME} \
	  .

run: dev-image
	docker run -p 48546:48546 -it ${APP_NAME} $(COMMAND)

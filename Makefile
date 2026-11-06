.PHONY: all

# https://public-inbox.org/public-inbox.git
PBI_VERSION = 1.9.0
PBI_SOURCE ?= snapshot
IMAGE_VERSION ?=${PBI_VERSION}
PUBLISH_VERSION_TAG ?= true
# https://git.kernel.org/pub/scm/git/git.git/
GIT_VERSION = 2.47.0
IMAGE_NAME ?= public-inbox
IMAGE_TOBUILD=${IMAGE_NAME}:${IMAGE_VERSION}
BASE_DISTRO ?= debian:stable-slim

REPO ?=
USER_ID ?=$(shell id -u)
DOCKER_BUILD_ARGS ?=

all:
	docker build ${DOCKER_BUILD_ARGS} -t ${IMAGE_TOBUILD} \
		--build-arg USER_UID=${USER_ID} \
		--build-arg BASE_DISTRO=${BASE_DISTRO} \
		--build-arg PBI_VERSION=${PBI_VERSION} \
		--build-arg PBI_SOURCE=${PBI_SOURCE} \
		--build-arg GIT_VERSION=${GIT_VERSION} \
		--pull .
	docker tag ${IMAGE_TOBUILD} ${IMAGE_NAME}

clean:
	docker container prune; \
	docker image ls|grep none|sed -e "s/\s\s*/ /g"|cut -d ' ' -f3|xargs docker rmi ${IMAGE_TOBUILD}

deploy:
	@echo "REPO=${REPO} IMAGE_TOBUILD=${IMAGE_TOBUILD} IMAGE_NAME=${IMAGE_NAME}"
ifeq (${PUBLISH_VERSION_TAG},true)
	docker tag ${IMAGE_NAME} ${REPO}${IMAGE_TOBUILD}
	docker push ${REPO}${IMAGE_TOBUILD}
endif
	docker tag ${IMAGE_NAME} ${REPO}${IMAGE_NAME}
	docker push ${REPO}${IMAGE_NAME}

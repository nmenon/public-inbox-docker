.PHONY: all

# https://public-inbox.org/public-inbox.git
PBI_VERSION = 1.6.0
# https://git.kernel.org/pub/scm/git/git.git/
GIT_VERSION = 2.30.0
IMAGE_NAME ?= public-inbox
IMAGE_TOBUILD=${IMAGE_NAME}:${PBI_VERSION}

REPO ?=
USER_ID ?=$(shell id -u)

all:
	docker build -t ${IMAGE_TOBUILD} \
		--build-arg USER_UID=${USER_ID} \
		--build-arg PBI_VERSION=${PBI_VERSION} \
		--build-arg GIT_VERSION=${GIT_VERSION} \
		--pull .
	docker tag ${IMAGE_TOBUILD} ${IMAGE_NAME}

clean:
	docker container prune; \
	docker image ls|grep none|sed -e "s/\s\s*/ /g"|cut -d ' ' -f3|xargs docker rmi ${IMAGE_TOBUILD}

deploy:
	@echo "REPO=${REPO} IMAGE_TOBUILD=${IMAGE_TOBUILD} IMAGE_NAME=${IMAGE_NAME}"
	docker tag ${IMAGE_NAME} ${REPO}${IMAGE_TOBUILD}
	docker tag ${IMAGE_NAME} ${REPO}${IMAGE_NAME}
	docker push ${REPO}${IMAGE_TOBUILD}
	docker push ${REPO}${IMAGE_NAME}

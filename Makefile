PACKAGE_NAME          := github.com/ethersphere/bee-clef
GOLANG_CROSS_VERSION  ?= v1.18.1

.PHONY: release
release:
	@docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
	if [ ! -f ".release-env" ]; then \
		echo "\033[91m.release-env is required for release\033[0m";\
		exit 1;\
	fi
	docker run \
		--rm \
		--privileged \
		-e CGO_ENABLED=1 \
		--env-file .release-env \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--mount type=bind,src=/proc,target=/proc \
		-v `pwd`:/go/src/$(PACKAGE_NAME) \
		-v `echo ${HOME}`/.docker/config.json:/root/.docker/config.json \
		-w /go/src/$(PACKAGE_NAME) \
		goreleaser/goreleaser-cross:${GOLANG_CROSS_VERSION} \
		release --rm-dist

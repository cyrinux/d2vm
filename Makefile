# Copyright 2021 Linka Cloud  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

MODULE = go.linka.cloud/d2vm

REPOSITORY = linkacloud

VERSION_SUFFIX = $(shell git diff --quiet || echo "-dev")
VERSION = $(shell git describe --tags --exact-match 2> /dev/null || echo "`git describe --tags $$(git rev-list --tags --max-count=1) 2> /dev/null || echo v0.0.0`-`git rev-parse --short HEAD`")$(VERSION_SUFFIX)
show-version:
	@echo $(VERSION)

DOCKER_IMAGE := linkacloud/d2vm

docker: docker-build docker-push

docker-push:
	@docker image push -a $(DOCKER_IMAGE)

docker-build:
	@docker image build -t $(DOCKER_IMAGE):$(VERSION) -t $(DOCKER_IMAGE):latest .

docker-run:
	@docker run --rm -i -t \
		--privileged \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(PWD):/build \
		-w /build \
		$(DOCKER_IMAGE) bash

build:
	@go build -o d2vm -ldflags "-s -w -X '$(MODULE).Version=$(VERSION)' -X '$(MODULE).BuildDate=$(shell date)'" ./cmd/d2vm

serve-docs:
	@docker run --rm -i -t --user=$(UID) -p 8000:8000 -v $(PWD):/docs linkacloud/mkdocs-material serve -f /docs/docs/mkdocs.yml -a 0.0.0.0:8000

.PHONY: build-docs
build-docs: clean-docs
	@docker run --rm -v $(PWD):/docs linkacloud/mkdocs-material build -f /docs/docs/mkdocs.yml -d build

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

GITHUB_PAGES_BRANCH := gh-pages

deploy-docs:
	@git branch -D gh-pages &> /dev/null || true
	@git checkout -b $(GITHUB_PAGES_BRANCH)
	@rm .gitignore && mv docs docs-src && mv docs-src/build docs && rm -rf docs-src
	@git add . && git commit -m "build docs" && git push origin --force $(GITHUB_PAGES_BRANCH)
	@git checkout $(GIT_BRANCH)

docs: build-docs deploy-docs

clean-docs:
	@rm -rf docs/build

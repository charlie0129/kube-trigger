# Copyright 2022 The KubeVela Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Go version used in build container
GO_VERSION  := 1.19
# Build container
BUILD_IMAGE ?= golang:$(GO_VERSION)-alpine
# The base image of containers
BASE_IMAGE  ?= gcr.io/distroless/static:nonroot

# Set this to anything to optimize binary for debugging, otherwise for release
DEBUG       ?=

# env to passthrough to the build container
GOFLAGS     ?=
GOPROXY     ?=
HTTP_PROXY  ?=
HTTPS_PROXY ?=

# Version string, use git tag by default
VERSION     ?= $(shell git describe --tags --always --dirty)

# Container image tag, same as VERSION by default
# if VERSION is not a semantic version (local uncommitted versions), then use latest
IMAGE_TAG ?= $(shell bash -c " \
  if [[ ! $(VERSION) =~ ^v[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}(-(alpha|beta)\.[0-9]{1,2})?$$ ]]; then \
    echo latest;     \
  else               \
    echo $(VERSION); \
  fi")

# Full Docker image name (e.g. docker.io/oamdev/kubetrigger:latest)
IMAGE_REPO_TAGS  ?= $(addsuffix /$(IMAGE_NAME):$(IMAGE_TAG),$(IMAGE_REPOS))

GOOS        ?=
GOARCH      ?=
# If user has not defined GOOS/GOARCH, use Go defaults. If user don't have Go, use linux/amd64.
OS          := $(if $(GOOS),$(GOOS),$(if $(shell go env GOOS),$(shell go env GOOS),linux))
ARCH        := $(if $(GOARCH),$(GOARCH),$(if $(shell go env GOARCH),$(shell go env GOARCH),amd64))

# Windows have .exe in the binary name
BIN_EXTENSION :=
ifeq ($(OS), windows)
    BIN_EXTENSION := .exe
endif

# Binary basename
BIN_BASENAME     := $(BIN)$(BIN_EXTENSION)
# Binary basename with extended info, i.e. version-os-arch
BIN_VERBOSE_BASE := $(BIN)-$(VERSION)-$(OS)-$(ARCH)$(BIN_EXTENSION)
# If the user set FULL_NAME, we will use the basename with extended info
FULL_NAME        ?=
BIN_FULLNAME     := $(if $(FULL_NAME),$(BIN_VERBOSE_BASE),$(BIN_BASENAME))
# Package filename (generated by `make package'). Use zip for Windows, tar.gz for all other platforms.
PKG_FULLNAME     := $(if $(FULL_NAME),$(BIN_VERBOSE_BASE),$(BIN_BASENAME)).tar.gz
ifeq ($(OS), windows)
    PKG_FULLNAME := $(subst .exe,,$(if $(FULL_NAME),$(BIN_VERBOSE_BASE),$(BIN_BASENAME))).zip
endif

# This holds build output, cache, and helper tools
DIST             := bin
BIN_VERBOSE_DIR  := $(DIST)/$(BIN)-$(VERSION)
# Full output path
OUTPUT           := $(if $(FULL_NAME),$(BIN_VERBOSE_DIR)/$(BIN_FULLNAME),$(DIST)/$(BIN_FULLNAME))

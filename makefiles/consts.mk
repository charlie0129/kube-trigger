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

# Set this to 1 to enable debugging output.
DBG_MAKEFILE ?=
ifeq ($(DBG_MAKEFILE),1)
    $(warning ***** starting Makefile for goal(s) "$(MAKECMDGOALS)")
    $(warning ***** $(shell date))
else
    # If we're not debugging the Makefile, don't echo recipes.
    MAKEFLAGS += -s
endif

# No, we don't want builtin rules.
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables
# Get rid of .PHONY everywhere.
MAKEFLAGS += --always-make

# Use bash explicitly
SHELL := /usr/bin/env bash -o errexit -o pipefail -o nounset

GO_VERSION  := 1.19
BUILD_IMAGE ?= golang:$(GO_VERSION)-alpine

# If user has not defined target, set some default value, same as host machine.
OS          := $(if $(GOOS),$(GOOS),$(if $(shell go env GOOS),$(shell go env GOOS),linux))
ARCH        := $(if $(GOARCH),$(GOARCH),$(if $(shell go env GOARCH),$(shell go env GOARCH),amd64))

# You can set these variables from env variables

# Optimzie binary for debugging, otherwise for release
DBG_BUILD   ?=

# Use full binary name with os-arch in it
FULL_NAME   ?=

# Plain old Go env
GOFLAGS     ?=
GOPROXY     ?=

# The base image of containers, with a default value
BASE_IMAGE  ?= gcr.io/distroless/static:nonroot

# Use git tags to set the version string
VERSION     ?= $(shell git describe --tags --always --dirty)

# Docker image tag, only uses semetic versioning, otherwise latest (e.g. local builds)
IMG_VERSION ?= $(shell bash -c " \
if [[ ! $(VERSION) =~ ^v[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}(-(alpha|beta)\.[0-9]{1,2})?$$ ]]; then \
  echo latest;     \
else               \
  echo $(VERSION); \
fi")

BIN_EXTENSION :=
ifeq ($(OS), windows)
    BIN_EXTENSION := .exe
endif

HTTP_PROXY  ?=
HTTPS_PROXY ?=

# Registries to push to
REGISTRY := docker.io/oamdev ghcr.io/kubevela

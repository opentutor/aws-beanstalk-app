SHELL:=/bin/bash
ENV?=test
AWS_REGION?=us-east-1
NODE_ENV?=$(ENV)
LOG_LEVEL_DIALOG?=info
CLASSIFIER_DOCKER_IMAGE?=uscictdocker/opentutor-classifier:1.1.0-alpha.6
GRAPHQL_API?=https://dev.opentutor.org/graphql

define NEWLINE


endef

DOTENV=env/$(ENV)/.env
$(DOTENV):
	@echo
	@echo "Trying to run the app locally?"
	@echo "You need a secrets-config file at $(DOTENV)"
	@echo "Check with project admins/README for details"
	@echo
	@echo
	@exit 1

VENV=.venv
$(VENV):
	$(MAKE) $(VENV)-update

.PHONY: $(VENV)-update
$(VENV)-update:
	[ -d $(VENV) ] || virtualenv -p python3 $(VENV)
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install -r requirements.txt

eb-ssh-%: 
	ENV=$* $(MAKE) eb-ssh

eb-ssh: $(VENV)
	. $(VENV)/bin/activate \
		&& eb use $(ENV) --region $(AWS_REGION) && eb ssh


.PHONY: clean
clean:
	@rm -rf build

build/publish/node_modules: build/publish
	cd build/publish && \
		npm ci

build/publish/.env: $(DOTENV)
	mkdir -p build/publish
	cp $(DOTENV) build/publish/.env

build/publish:
	mkdir -p build/publish
	rsync -rv \
			--exclude node_modules \
		publish/ build/publish/

build: build/publish

archive:
	mkdir -p archive

models:
	mkdir -p models

.PHONY: run
run: clean build/publish/.env archive models
	NODE_ENV=$(ENV) \
	ENV=$(ENV) \
	LOG_LEVEL_DIALOG=$(LOG_LEVEL_DIALOG) \
	docker-compose up

.PHONY: stop
stop: 
	docker-compose down --remove-orphans


.PHONY: sync-%
sync-%:
	docker run \
		-it \
		--rm \
		-v $(PWD)/data:/data \
	$(CLASSIFIER_DOCKER_IMAGE) sync --lesson $* --url $(GRAPHQL_API) --output /data

.PHONY: traindefault
traindefault:
	docker run \
		-it \
		--rm \
		-v $(PWD)/data:/data \
		-v $(PWD)/shared:/shared \
		-v $(PWD)/models/default:/output \
	$(CLASSIFIER_DOCKER_IMAGE) traindefault --data /data/ --output /output --shared /shared

.PHONY: train-%
train-%:
	docker run \
		-it \
		--rm \
		-v $(PWD)/data:/data \
		-v $(PWD)/shared:/shared \
		-v $(PWD)/models/$*:/output \
	$(CLASSIFIER_DOCKER_IMAGE) train --data /data/$* --output /output --shared /shared

LICENSE:
	@echo "you must have a LICENSE file" 1>&2
	exit 1

LICENSE_HEADER:
	@echo "you must have a LICENSE_HEADER file" 1>&2
	exit 1

.PHONY: license
license: LICENSE LICENSE_HEADER node_modules
	npm run license:fix

.PHONY: test-license
test-license: LICENSE LICENSE_HEADER node_modules
	npm run test:license

.PHONY: format
format: node_modules
	npm run format

.PHONY: test-format
test-format: node_modules
	npm run test:format

.PHONY: test
test-run: 
	NODE_ENV=$(ENV) \
	ENV=$(ENV) \
	LOG_LEVEL_DIALOG=$(LOG_LEVEL_DIALOG) \
	docker-compose -f docker-compose.yml -f docker-compose-e2e.yml up

.PHONY: test-cypress
test-cypress: 
	NODE_ENV=$(ENV) \
	ENV=$(ENV) \
	LOG_LEVEL_DIALOG=$(LOG_LEVEL_DIALOG) \
	cd test && make test

.PHONY: test-cypress-with-ui
test-cypress-with-ui:
	NODE_ENV=$(ENV) \
	ENV=$(ENV) \
	LOG_LEVEL_DIALOG=$(LOG_LEVEL_DIALOG) \
	cd test && make test-ui

node_modules:
	npm ci

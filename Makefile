ENV?=test
EFS_FILE_SYSTEM_ID?=
NODE_ENV?=$(ENV)
LOG_LEVEL_DIALOG?=info

DOTENV=env/$(ENV)/.env
$(DOTENV):
	@echo
	@echo "Trying to run the app locally?"
	@echo "You need a secrets-config file at $(DOTENV)"
	@echo "Check with project admins/README for details"
	@echo
	@echo
	@exit 1

.PHONY: clean
clean:
	@rm -rf build deploy.zip

build/run/node_modules: build/run
	cd build/run && \
		npm ci

build/run/.env: $(DOTENV)
	mkdir -p build/run
	cp $(DOTENV) build/run/.env

build/run:
	mkdir -p build/run
	rsync -rv \
			--exclude node_modules \
		publish/ build/run/

build/deploy:
	# put everything we want in our beanstalk deploy.zip file
	# into a build/deploy folder.
	@if [ -z "$(EFS_FILE_SYSTEM_ID)" ] ; then \
		echo "required env var EFS_FILE_SYSTEM_ID unset.";\
		echo "See https://github.com/opentutor/terraform-opentutor-aws-beanstalk/blob/main/template/README.md"; \
		false ; \
	fi
	mkdir -p build/deploy
	cp -r ebs/bundle build/deploy/bundle
	# Must set the env-specific EFS_FILE_SYSTEM_ID in an .ebextensions config file
	# to have our beanstalk-env instances mount this network file system
	# (used for reading/writing trained models)
	# ...
	# sed -i option works differently on linux and mac
	# so have to output to a temp file and then copy back
	cd build/deploy/bundle/.ebextensions \
		&& sed 's/VAR_EFS_FILE_SYSTEM_ID/$(EFS_FILE_SYSTEM_ID)/g' efs.config > efs.config.tmp \
		&& mv efs.config.tmp efs.config
	cp -r ./nginx build/deploy/bundle/nginx
	mkdir -p build/deploy/bundle/classifier
	# for now at least, packaging up our default model
	# and word2vec.bin directly into the deploy.zip for beanstalk
	mkdir -p ./models_deployed
	cp -r ./models_deployed build/deploy/bundle/classifier/models_deployed
	mkdir -p ./shared
	cp -r ./shared build/deploy/bundle/classifier/shared

deploy.zip:
	$(MAKE) clean build/deploy
	cd build/deploy/bundle && zip -r $(PWD)/deploy.zip .

archive:
	mkdir -p archive

models:
	mkdir -p models

models_deployed:
	mkdir -p models_deployed

.PHONY: run
run: clean build/run/.env archive models models_deployed
	NODE_ENV=$(ENV) \
	ENV=$(ENV) \
	LOG_LEVEL_DIALOG=$(LOG_LEVEL_DIALOG) \
	docker-compose up

.PHONY: stop
stop: 
	docker-compose down --remove-orphans

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

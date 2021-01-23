.PHONY: test-stop
test-stop:
	docker-compose -f ../docker-compose.yml -f docker-compose.yml down --remove-orphans

.PHONY: test
test: test
	docker-compose -f ../docker-compose.yml -f docker-compose.yml up --exit-code-from cypress

.PHONY: test-ui
test-ui: test-stop
	xhost +
	docker-compose -f ../docker-compose.yml -f docker-compose.yml -f cypress-open.yml up --exit-code-from cypress

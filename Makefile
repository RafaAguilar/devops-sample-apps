# Go and PHP applications Makefile
# Provides targets for local development and Docker operations for both golang and PHP apps

.PHONY: help build-local run-local clean-local build-image run-image clean-all kill-apps
.PHONY: golang_build-local golang_run-local golang_build-image golang_run-image golang_clean-local
.PHONY: php_build-local php_run-local php_build-image php_run-image php_clean-local
.PHONY: build run

.DEFAULT_GOAL := help

PHP_PID_FILE = ./php.pid
GO_PID_FILE= ./go.pid

help:
	@echo "Available targets:"
	@echo "GLOBAL (work on both apps):"
	@echo "  build-local     - Build both applications locally"
	@echo "  run-local       - Run both applications locally (ports: golang=8080, php=8082)"
	@echo "  build-image     - Build both Docker images"
	@echo "  run-image       - Run both Docker containers (ports: golang=8080, php=8081)"
	@echo "  clean-local     - Clean up local build artifacts for both apps"
	@echo "  clean-all       - Clean up all build artifacts and Docker images for both apps"
	@echo ""
	@echo "GOLANG APP INDIVIDUAL:"
	@echo "  golang_build-local   - Build only the Go application locally"
	@echo "  golang_run-local     - Run only the Go application locally (port: 8080)"
	@echo "  golang_build-image   - Build only the Go Docker image"
	@echo "  golang_run-image     - Run only the Go Docker container (port: 8080)"
	@echo "  golang_clean-local   - Clean up local build artifacts for golang"
	@echo ""
	@echo "PHP APP INDIVIDUAL:"
	@echo "  php_build-local      - Build only the PHP application locally"
	@echo "  php_run-local        - Run only the PHP application locally (port: 8082)"
	@echo "  php_build-image      - Build only the PHP Docker image"
	@echo "  php_run-image        - Run only the PHP Docker container (port: 8081)"
	@echo "  php_clean-local      - Clean up local build artifacts for php"

# ========================================
# GLOBAL TARGETS
# ========================================
build-local: golang_build-local php_build-local

run-local: golang_run-local php_run-local

build-image: golang_build-image php_build-image

run-image: golang_run-image php_run-image

clean-local: golang_clean-local php_clean-local

clean-all: clean-local
	#TODO: stop containers using images
	#TODO: calculate image tag from environment and using it everywhere
	@echo "Cleaning Docker images..."
	-docker kill `docker ps --all --filter "ancestor=golang:v0.1" --format "{{.ID}}"`
	-docker kill `docker ps --all --filter "ancestor=php:v0.1" --format "{{.ID}}"`
	-docker rm `docker ps --all --filter "ancestor=php:v0.1" --format "{{.ID}}"`
	-docker rm `docker ps --all --filter "ancestor=golang:v0.1" --format "{{.ID}}"`
	-docker rmi golang:v0.1 php:v0.1

kill-apps:
	@if [ -f "$(PHP_PID_FILE)" ]; then \
		echo "Attempting to kill PHP process with PID from $(PHP_PID_FILE)..."; \
		kill $$(cat $(PHP_PID_FILE)); \
		rm "$(PHP_PID_FILE)"; \
		echo "Process killed and $(PHP_PID_FILE) removed."; \
	else \
		echo "No PID file found at $(PHP_PID_FILE). Is the application running?"; \
	fi

	@if [ -f "$(GO_PID_FILE)" ]; then \
		echo "Attempting to kill GO process with PID from $(GO_PID_FILE)..."; \
		kill $$(cat $(GO_PID_FILE)); \
		rm "$(GO_PID_FILE)"; \
		echo "Process killed and $(GO_PID_FILE) removed."; \
	else \
		echo "No PID file found at $(GO_PID_FILE). Is the application running?"; \
	fi

# ========================================
# GOLANG APP TARGETS
# ========================================
golang_build-local:
	@echo "Building Go application locally..."
	@mkdir -p golang/bin
	cd golang && go build -o bin/main main.go

golang_run-local:
	@echo "Running Go application locally on port 80..."
	@echo "Note: Make sure golang/tmp/file.p12 exists and is accessible"
	@cd golang && [ ! -f tmp/file.p12 ] && echo "ERROR: golang/tmp/file.p12 not found" && exit 1 || echo "File found, proceeding..."
	@cd golang && cp tmp/file.p12 . && go run main.go & echo $$! > $(GO_PID_FILE)

golang_build-image:
	@echo "Building Docker image for golang..."
	cd golang && docker build -f go.containerfile . -t golang:v0.1

golang_run-image: golang_build-image
	@echo "Running Docker container for golang on port 9191..."
	cd golang && docker run -d -p 127.0.0.1:9191:80 --volume ./tmp/file.p12:/app/file.p12 golang:v0.1

golang_clean-local:
	@echo "Cleaning local build artifacts for golang..."
	@rm -rf golang/bin/
	@rm -f golang/main
	@rm -f golang/file.p12

# ========================================
# PHP APP TARGETS
# ========================================
php_build-local:
	@echo "Setting up PHP application locally..."
	@mkdir -p php/bin
	cd php && cp config.prod config

php_run-local:
	@echo "Running PHP application locally on port 9090..."
	@(cd php && cp config.prod config && php -S localhost:9090) & echo $$! > $(PHP_PID_FILE)

php_build-image:
	@echo "Building Docker image for PHP..."
	cd php && docker build -f php.containerfile . -t php:v0.1

php_run-image: php_build-image
	@echo "Running Docker container for PHP on port 9090..."
	cd php && docker run -d -p 127.0.0.1:9090:80 --volume ./config.dev:/var/www/html/config php:v0.1

php_clean-local:
	@echo "Cleaning local build artifacts for PHP..."
	@rm -f php/config
	@rm -rf php/bin

# ========================================
# ALIASES
# ========================================
build: build-local
run: run-local
kill: kill-apps
clean: clean-all
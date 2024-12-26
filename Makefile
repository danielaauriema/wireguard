MAKEFLAGS += --no-print-directory

NETWORK_NAME=wg_test
IMG_TAG=wireguard:test

V_TEST=-v "$(PWD)/test:/opt/test"
V_WIREGUARD=-v "$(PWD)/startup/wireguard:/opt/wireguard"

DOCKER_RUN=-v "$(PWD)/data:/data" \
	--cap-add=NET_ADMIN \
	--cap-add=SYS_MODULE \
	--sysctl="net.ipv4.conf.all.src_valid_mark=1" \
	--network $(NETWORK_NAME) \
	$(IMG_TAG)

SERVER_CONFIG=-v "$(PWD)/test/config.yml:/opt/test/config.yml" \
	-e SERVER__CONFIG_FILE="/opt/test/config.yml" \
	--sysctl="net.ipv4.ip_forward=1"

.PHONI: clean build test ci-test run up down

clean:
	rm -Rf $(PWD)/data/wireguard

build:
	@docker build --no-cache -t $(IMG_TAG) .

test: up
	docker run -d --rm \
	--name wg_server \
	$(SERVER_CONFIG) \
	$(V_WIREGUARD) \
	$(DOCKER_RUN)

	docker run -d --rm \
	--name wg_client \
	$(V_TEST) \
	$(V_WIREGUARD) \
	$(DOCKER_RUN) \
	tail -f /dev/null

	docker exec -it \
    wg_client \
    /opt/test/client.sh

	docker run -it --rm \
	$(V_TEST) \
	$(V_WIREGUARD) \
	$(DOCKER_RUN) \
	/opt/test/test.sh

	@$(MAKE) down

ci-test: up
	docker run -d --rm \
	--name wg_server \
	$(SERVER_CONFIG) \
	$(DOCKER_RUN)

	docker run -d --rm \
	--name wg_client \
	$(V_TEST) \
	$(DOCKER_RUN) \
	tail -f /dev/null

	docker exec \
    wg_client \
    /opt/test/client.sh

	docker run --rm \
	$(V_TEST) \
	$(DOCKER_RUN) \
	/opt/test/test.sh

	@$(MAKE) down

run:
	@docker compose up

up:
	@echo "*** Starting all services..."
	@docker network create --driver=bridge $(NETWORK_NAME)
	@chmod -R +x ./startup ./test

down:
	@echo "*** Stopping all services..."
	@docker stop wg_client wg_server || true
	@docker network rm $(NETWORK_NAME) || true

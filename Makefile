MAKEFLAGS += --no-print-directory

NETWORK_NAME=wg_test
IMG_TAG=auriema/wireguard:test

V_TEST=-v "$(PWD)/test:/opt/test"
V_WIREGUARD=-v "$(PWD)/wireguard:/opt/wireguard"

DOCKER_RUN=-v "$(PWD)/data:/data" \
	--cap-add=NET_ADMIN \
	--cap-add=SYS_MODULE \
	--sysctl="net.ipv4.conf.all.src_valid_mark=1" \
	--network $(NETWORK_NAME) \
	$(IMG_TAG)
IPV4_FWD=--sysctl="net.ipv4.ip_forward=1"

.PHONI: clean build test ci-test run up down

clean:
	rm -Rf $(PWD)/data/wireguard

build_b1:
	@docker build -f v1.Dockerfile --no-cache -t auriema/wireguard:b1 .

build:
	@docker build --no-cache -t $(IMG_TAG) .

test: up
	docker run -d --rm \
	--name wg_server \
	$(V_WIREGUARD) \
	$(IPV4_FWD) \
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
	$(IPV4_FWD) \
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

run: up
	docker run -it --rm \
	--name wg_server \
	-p "53:53/udp" \
	-p "51820:51820/udp" \
	$(IPV4_FWD) \
	$(DOCKER_RUN)

	@$(MAKE) down

up:
	@echo "*** Starting all services..."
	@docker network create --driver=bridge $(NETWORK_NAME)

down:
	@echo "*** Stopping all services..."
	@docker stop wg_client wg_server || true
	@docker network rm $(NETWORK_NAME) || true

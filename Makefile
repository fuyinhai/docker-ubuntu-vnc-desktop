.PHONY: build-web build run

# Default values for variables
REPO  ?= ubuntu
TAG   ?= ${TAG}
# you can choose other base image versions
IMAGE ?= ubuntu:18.04
# IMAGE ?= nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
# choose from supported flavors (see available ones in ./flavors/*.yml)
FLAVOR ?= $(TAG)
# armhf or amd64
ARCH ?= amd64

# These files will be generated from teh Jinja templates (.j2 sources)
templates = Dockerfile rootfs/etc/supervisor/conf.d/supervisord.conf

build-web: Dockerfile-web
	docker build -t $(REPO):$(TAG)-web -f Dockerfile-web .
	docker run -v $(shell pwd):/usr/local/share $(REPO):$(TAG)-web cp /usr/local/lib/web/frontend/* /usr/local/share/rootfs/usr/local/lib/web/frontend -R

build: $(templates) Dockerfile.j2 Makefile
	docker build -t $(REPO):$(TAG) .

# Test run the container
# the local dir will be mounted under /src read-only
run:
	docker run --privileged --rm -it \
		-p 6080:8080 -p 6081:443 \
		-v ${PWD}:/src \
		-e USERNAME=ubuntu -e PASSWORD=password123 -e HOME=/usr/local/share\
		-e ALSADEV=hw:2,0 \
		-e SSL_PORT=443 \
		-e RELATIVE_URL_ROOT=approot \
		-e OPENBOX_ARGS="--startup /usr/bin/galculator" \
		-v ${PWD}/ssl:/etc/nginx/ssl \
		--device /dev/snd \
		--name $(TAG) \
		$(REPO):$(TAG)

# Connect inside the running container for debugging
shell:
	docker exec -it $(REPO)-$(TAG) bash

# Generate the SSL/TLS config for HTTPS
gen-ssl:
	mkdir -p ssl
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout ssl/nginx.key -out ssl/nginx.crt

clean:
	rm -f $(templates)

extra-clean:
	docker rmi $(REPO):$(TAG)
	docker image prune -f

# Run jinja2cli to parse Jinja template applying rules defined in the flavors definitions
%: %.j2 flavors/$(FLAVOR).yml Dockerfile.j2 Makefile
	docker run -v $(shell pwd):/data vikingco/jinja2cli \
		-D flavor=$(FLAVOR) \
		-D image=$(IMAGE) \
		-D localbuild=$(LOCALBUILD) \
		-D arch=$(ARCH) \
		$< flavors/$(FLAVOR).yml > $@ || rm $@

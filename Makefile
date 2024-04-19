NAME=squid
SQUID_VERSION=6.9

REPO_HUB=jinwoo
TAGNAME:=$(SQUID_VERSION)


all: build


build:
	@docker build --build-arg SQUID_VERSION=$(SQUID_VERSION) --tag=$(REPO_HUB)/$(NAME):$(SQUID_VERSION) .


push: push_hub tag_latest


push_hub:
	docker push $(REPO_HUB)/$(NAME):$(TAGNAME)


tag_latest:
	docker tag  $(REPO_HUB)/$(NAME):$(TAGNAME) $(REPO_HUB)/$(NAME):latest
	docker push $(REPO_HUB)/$(NAME):latest
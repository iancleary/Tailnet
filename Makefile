PHONY: help

# Setup Application ID
TLD?= com
DOMAIN?= github
NS?= iancleary
REPO?= Taildock

APPID=$(TLD).$(DOMAIN).$(NS).$(REPO)


# Shell that make should use
SHELL:=bash

# - to suppress if it doesn't exist
-include make.env

help:
# http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
# adds anything that has a double # comment to the phony help list
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ".:*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

install:
install: ## Install via meson and ninja
	meson build --prefix=/usr
	cd build && ninja && ninja install

uninstall:
uninstall: ## Uninstall via meson and ninja
	sudo ninja -C build uninstall

run:
run: ## Run application build from meson and ninja
	$(APPID)

update-icon-cache:
update-icon-cahge: ## Refresh Icon Cache
	sudo update-icon-caches /usr/share/icons/*

setup:
setup: ## Setup flatpak remotes and Sdk
	@flatpak remote-add --if-not-exists --system appcenter https://flatpak.elementary.io/repo.flatpakrepo
	@flatpak install -y appcenter io.elementary.Platform io.elementary.Sdk

flatpak:
flatpak:  ## Install via flatpak
	@flatpak-builder build $(APPID).yml --user --install --force-clean

remove:
remove: ## Remove flatpak
	flatpak remove $(APPID)



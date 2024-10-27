include ./makefiles_inc/makefile_colored_help.inc
.DEFAULT_GOAL := help

##########################################################################################
## prerequisites:
requirements: ## install all requirements
	mkdir -p ./external-deps && \
	( \
	$(MAKE) clone-or-pull GIT_REPO_URL=https://github.com/OliPelz/public-shell-scripts.git TARGET_DIR=./external-deps/public-shell-scripts TO_GITIGNORE=true; \
	)

##########################################################################################
## dotfiles specific:
install:  ## install all dotfiles
	@export DOTFILES_REPO_FULL_PATH=$$PWD; \
	export PROVISIONING_CONFIG_FULL_PATH=$${DOTFILES_REPO_FULL_PATH}/basic-provisioning.yaml; \
	for i in make_scripts/[0-9]*; do set -e && ./$$i; done
clean:    ## clean all dotfiles
	@export DOTFILES_REPO_FULL_PATH=$$PWD; \
	export PROVISIONING_CONFIG_FULL_PATH=$${DOTFILES_REPO_FULL_PATH}/basic-provisioning.yaml; \
	./make_scripts/__remove_all_dotfiles.sh \
	rm $$HOME/.env/__compiled_envs_for_shells/bash-complete-env.source.sh.zsh

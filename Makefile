include ./makefiles_inc/makefile_colored_help.inc
.DEFAULT_GOAL := help

##########################################################################################
## prerequisites:
requirements: git-add-hooks  ## install all requirements
	mkdir -p ./external-deps && \
	( \
	$(MAKE) git-clone-or-pull GIT_REPO_URL=https://github.com/OliPelz/public-shell-scripts.git TARGET_DIR=./external-deps/public-shell-scripts TO_GITIGNORE=true; \
	)

##########################################################################################
## build:
compile:  requirements ## install all dotfiles
	@export DOTFILES_REPO_FULL_PATH=$$PWD; \
	for i in __make_scripts/[0-9]*; do set -e && ./$$i; done
clean:    ## clean all dotfiles
	@export DOTFILES_REPO_FULL_PATH=$$PWD; \
	./__make_scripts/__remove_all_dotfiles.sh; \
	rm -rf makefiles_inc external-deps; \
	rm $$HOME/.env/__compiled_envs_for_shells/shell-complete-env.source.sh.zsh

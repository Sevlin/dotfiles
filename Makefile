SHELL:=/bin/bash

.DEFAULT_GOAL:=all

profile: clean
	@echo "[ bash ] Creating nix-profile.sh"
	@cat .bash_profile .bash_aliases \
	| sed '/# shellcheck /d' > nix-profile.sh \
	&& chmod +x nix-profile.sh

bashrc:
	@echo "[ bash ] Installing .bashrc"
	@cat .bashrc | sed '/# shellcheck /d' > ~/.bashrc

bash_profile: bashrc
	@echo "[ bash ] Installing .bash_profile"
	@cat .bash_profile | sed '/# shellcheck /d' > ~/.bash_profile

bash_aliases: bash_profile
	@echo "[ bash ] Installing .bash_aliases"
	@cat .bash_aliases | sed '/# shellcheck /d' > ~/.bash_aliases

bash: bash_profile bash_aliases

inputrc:
	@echo "[ inputrc ] Installing .inputrc"
	@cat .inputrc > ~/.inputrc

gitconfig:
	@echo "[ git ] Installing .gitconfig"
	@cat .gitconfig > ~/.gitconfig

gitignore:
	@echo "[ git ] Installing .gitignore"
	@cat .gitignore > ~/.gitignore

git: gitconfig gitignore

vimrc:
	@echo "[ vim ] Installing .vimrc"
	@cat .vimrc > ~/.vimrc

vim: vimrc

install: bash inputrc git vim

all: clean install profile

clean:
	@echo "[ clean ] Cleaning up"
	@rm -f nix-profile.sh


CONTEXTO = dind-ubuntu-k8s
SHELL := /bin/bash
CURRENT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
VERSION:=$(shell cat .version)
ROOT_DIR := $(HOME)

NO_COLOR=\x1b[0m
GREEN_COLOR=\x1b[32;01m
RED_COLOR=\x1b[31;01m
ORANGE_COLOR=\x1b[33;01m

OK_STRING=$(GREEN_COLOR)[OK]$(NO_COLOR)
ERROR_STRING=$(RED_COLOR)[ERRORS]$(NO_COLOR)
WARN_STRING=$(ORANGE_COLOR)[WARNINGS]$(NO_COLOR)


#############
# FUNCTIONS #
#############


define pergunta_critical
    echo -e "\t$(RED_COLOR)$(1)$(NO_COLOR) "
		while true; do \
	    read -p '          Informe: (y/n)' yn ; \
	    case $$yn in  \
	        y|Y ) echo "              Continuando..."; break ;; \
	        n|N ) echo "              Ok... saindo, cancelando, desistindo...."; sleep 2; exit 255 ;; \
	        * ) echo "              Por favor, escolha y ou n." ;; \
	     esac ; \
	  done
endef
define msg_critical
    echo -e "$(RED_COLOR)-->[$(1)]$(NO_COLOR)\n"
endef

define msg_warn
    echo -e "$(ORANGE_COLOR)-->[$(1)]$(NO_COLOR)\n"
endef

define msg_ok
    echo -e "$(GREEN_COLOR)-->[$(1)]$(NO_COLOR)\n"
endef

define menu
    echo -e "$(GREEN_COLOR)[$(1)]$(NO_COLOR)"
endef





########################
# BINARIOS E PROGRAMAS #
########################
FIND_MAKE=find $(ROOT_DIR) -name Makefile



.PHONY: ajuda
ajuda: help

.PHONY: limpa_tela
limpa_tela:
	@clear

.PHONY: exec_bash_env
exec_bash_env: ## Run bash (container) simulate .env
	docker run -it --rm --env-file $(CURRENT_DIR)/.env $(CONTEXTO) bash


.PHONY: exec_bash_registry
exec_bash_registry: ## Run bash (container) simulate registry
	docker run -it --rm -e REGISTRY_ADDRESS=https://registry.teste.com $(CONTEXTO) bash

.PHONY: exec_bash_gitlab
exec_bash_gitlab: ## Run bash (container) simulate gitlab
	docker run -it --rm -e GITLAB_ADDRESS=https://gitlab.teste.com $(CONTEXTO) bash

.PHONY: exec_bash
exec_bash: ## Run bash (container)
	docker run -it --rm  \
	-e REGISTRY_ADDRESS=registry.teste.com \
	-e REGISTRY_PORT=5000 \
	-e GITLAB_ADDRESS=gitlab.teste.com  \
	$(CONTEXTO) bash

.PHONY: send_git
send_git: ## Send to git (build, tests and send)
	git pull
	make build
	git add :/ --all && git commit -m "$(VERSION)" --all || echo
	git push



.PHONY: build
build: ## Local build
	docker build -t  $(CONTEXTO) .
	make test-all

.PHONY: test-all
test-all: limpa_tela ## Tests (all)
	make test-docker
	make test-kubectl
	make test-python
	make test-pip
	make test-git

.PHONY: test-git
test-git:  ## Git tests
	@echo ""
	@$(call msg_warn,"git version...")
	@sleep 1; docker run --name teste-list-docker-$(CONTEXTO) --rm -it -v /var/run/docker.sock:/var/run/docker.sock $(CONTEXTO) git --version | \
	  grep -q "git version " && \
	  echo -e "\t$(GREEN_COLOR)Get git version = OK $(NO_COLOR) " || \
		echo -e "\t$(RED_COLOR)Get git version = NOK $(NO_COLOR) "

.PHONY: test-pip
test-pip:  ## Pip tests
	@echo ""
	@$(call msg_warn,"pip version...")
	@sleep 1; docker run --name teste-list-docker-$(CONTEXTO) --rm -it -v /var/run/docker.sock:/var/run/docker.sock $(CONTEXTO) pip --version && \
	  echo -e "\t$(GREEN_COLOR)Get pip version = OK $(NO_COLOR) " || \
		echo -e "\t$(RED_COLOR)Get pip version = NOK $(NO_COLOR) "

.PHONY: test-python
test-python:  ## Python3 tests
	@echo ""
	@$(call msg_warn,"Python3 version...")
	@sleep 1; docker run --name teste-list-docker-$(CONTEXTO) --rm -it -v /var/run/docker.sock:/var/run/docker.sock $(CONTEXTO) python3 --version | \
	  grep -q "Python " && \
	  echo -e "\t$(GREEN_COLOR)Get python3 version = OK $(NO_COLOR) " || \
		echo -e "\t$(RED_COLOR)Get python3 version = NOK $(NO_COLOR) "

.PHONY: test-kubectl
test-kubectl:  ## Kubectl tests
	@echo ""
	@$(call msg_warn,"Kubectl version...")
	@sleep 1; docker run --name teste-list-docker-$(CONTEXTO) --rm -it -v /var/run/docker.sock:/var/run/docker.sock $(CONTEXTO) kubectl version -c | \
	  grep -q "Client Version: version.Info{Major" && \
	  echo -e "\t$(GREEN_COLOR)Get kubectl version = OK $(NO_COLOR) " || \
		echo -e "\t$(RED_COLOR)Get kubectl version = NOK $(NO_COLOR) "


.PHONY: test-docker
test-docker:  ## Docker tests
	@echo ""
	@$(call msg_warn,"Docker basic...")
	@sleep 1; docker run --name teste-list-docker-$(CONTEXTO) --rm -it -v /var/run/docker.sock:/var/run/docker.sock $(CONTEXTO) docker ps && \
	  echo -e "\t$(GREEN_COLOR)List containers = OK $(NO_COLOR) " || \
		echo -e "\t$(RED_COLOR)List containers = NOK $(NO_COLOR) "
	@sleep 1; docker run --name teste-list-docker-$(CONTEXTO) --rm -it -v /var/run/docker.sock:/var/run/docker.sock $(CONTEXTO) docker ps | \
	    grep -q teste-list-docker-$(CONTEXTO) && \
			echo -e "\t$(GREEN_COLOR)Get container name = OK$(NO_COLOR) " || \
			echo -e "\t$(RED_COLOR)Get container name = NOK$(NO_COLOR) "

.PHONY: sair
sair:
	@clear

.PHONY: help
help: limpa_tela
	@$(call menu, "============== $(CONTEXTO) ==============")
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)  | awk 'BEGIN {FS = ":.*?## "}; {printf "\t\033[36m%-30s\033[0m %s\n", $$1, $$2}'

SHELL = bash
VENV = env

ifndef DEPLOYSERVER
	DEPLOYSERVER = ant
endif

ifndef DEPLOYDIR
	DEPLOYDIR = ~/public_html/grape/docs
endif

docs: venv sphinx
	@echo -n "== $$(tput setaf 3; tput bold)Updating GRAPE documentation...$$(tput sgr0)"
	@source $(VENV)/bin/activate && make -C docs deploy DEPLOYSERVER=$(DEPLOYSERVER) DEPLOYDIR=$(DEPLOYDIR) &> .html.log 
	@echo "$$(tput setaf 2; tput bold)done$$(tput sgr0)"

venv: 
	@[ -d $(VENV) ] || virtualenv $(VENV)

sphinx: venv
	@source $(VENV)/bin/activate && [[ "$(shell command -v sphinx-build)" ]] || pip install sphinx sphinx_rtd_theme

test: compare.sh
	@./compare.sh

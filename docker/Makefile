-include common.mk
-include $(PROCS:%=process/%/Rules.mk)

VERBOSE ?= 1
PROC_TOOLS := $(foreach p,$(PROCS),$(foreach t,$($(shell echo $(p) | tr a-z A-Z)_TOOLS),.$(p)_$(t)))

.PHONY: processes tools $(TOOLS) $(PROC_TOOLS) base python java

all: java python processes

processes: $(PROC_TOOLS)

tools: $(TOOLS)

logs logs/tool logs/process:
	@mkdir -p $@

$(TOOLS): TOOL=$(shell echo $@ | cut -d- -f1| tr a-z A-Z)
$(TOOLS): logs/tool
	@[ $(VERBOSE) ] && echo Building tool image $(NS)/$@:$($(TOOL)_VER) || true
	@docker build --build-arg $(TOOL)_VER=$($(TOOL)_VER) -t $(NS)/$@:$($(TOOL)_VER) tool/$@ > $</$@.log
	@[ $(PUSH) ] && docker push $(NS)/$@:$($(TOOL)_VER) || true
	@[ $(VERBOSE) ] && [ "$(TAGS)" ] && echo Creating $(NS)/$@:$($(TOOL)_VER) image tags: $(TAGS) || true
	@$(foreach t,$(TAGS),docker tag $(NS)/$@:$($(TOOL)_VER) $(t);)
	@$(foreach t,$(TAGS),[ $(PUSH) ] && docker push $(t) || true;) 

$(PROC_TOOLS): INFO=$(subst _, ,$(subst .,,$@))
$(PROC_TOOLS): PROC=$(word 1,$(INFO))
$(PROC_TOOLS): PROC_TOOL=$(word 2,$(INFO))
$(PROC_TOOLS): TOOL=$(shell echo $(PROC_TOOL) | tr a-z A-Z)
$(PROC_TOOLS): logs/process
	@[ $(VERBOSE) ] && echo Building process image $(NS)/$(PROC):$(PROC_TOOL)-$($(TOOL)_VER) || true
	@docker build $($(TOOL)_ARGS:%=--build-arg %) \
		-t $(NS)/$(PROC):$(PROC_TOOL)-$($(TOOL)_VER) process/$(PROC)/$(PROC_TOOL) > $</$(PROC)_$(PROC_TOOL).log
	@[ $(PUSH) ] && docker push $(NS)/$(PROC):$(PROC_TOOL)-$($(TOOL)_VER) || true
	@[ $(VERBOSE) ] && [ "$(TAGS)" ] && echo Creating $(NS)/$(PROC):$(PROC_TOOL)-$($(TOOL)_VER) image tags: ${TAGS} || true
	@$(foreach t,$(TAGS),docker tag $(NS)/$(PROC):$(PROC_TOOL)-$($(TOOL)_VER) $(t);)
	@$(foreach t,$(TAGS),[ $(PUSH) ] && docker push $(t) || true;) 

base: ADDITIONAL_VER := GLIBC_$(GLIBC_VER)
base: VER_CMD=docker run --rm $(NS)/$@:latest cat /etc/alpine-release
base: BUILD_ARGS=--build-arg GLIBC_VER=$(GLIBC_VER)

java: base
java: VER_CMD=docker run --rm $(NS)/$@:latest java -version 2>&1 | head -1

python: base
python: VER_CMD=docker run --rm $(NS)/$@:latest python --version 2>&1

base java python: logs
	@[ $(VERBOSE) ] && echo -n Building container for $@ || true
	@docker build $(BUILD_ARGS) -t $(NS)/$@:latest $@ > $</$@.log
	@$(eval VER := $(lastword $(shell $(VER_CMD))))
	@echo -n " $(VER)"
	@[ $(ADDITIONAL_VER) ] && echo " $(ADDITIONAL_VER)" || echo
	@docker tag $(NS)/$@:latest $(NS)/$@:$(VER)
	@[ $(PUSH) ] && docker push $(NS)/$@:$(VER) >> $</$@.log || true
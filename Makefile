###
## Change it only when you add new file to compile
## other config please see config/...
## config.mk is generated by Makefile, so don't change it.

SHELL=/bin/bash

BASEDIR=$(shell pwd)

include include.mk

sinclude config/config_all.mk


## this is defined in config/config_all.mk
#filedirs-y=common disk stream
.PHONY: $(filedirs-y)


all: generate_config createdir filesbuild dep-before static dyn

generate_config:
	@ [ -f $(CONFIG_FILE) ] && rm -rf $(CONFIG_FILE); \
		DATA=`date +%Y%m%d%H%M%S`; \
		GITVERSION=`./tools/setlocalversion`; \
		BUILD_GIT_VERSION=$$DATA.git-$$GITVERSION; \
		echo "# generated git version" >> $(CONFIG_FILE); \
		echo "#define BUILD_GIT_VERSION $$BUILD_GIT_VERSION" >> $(CONFIG_FILE)

filesbuild:
	@for i in $(filedirs-y) $(filedirs-d-y); do \
        $(ECHO) "\n\t Build $$i\n"; \
        cd $$i; make; cd ..;\
    done

## check build-in files before make static and dyn
dep-before:
	@for i in $(buildin-files); do   \
		fname=$$i ;   \
		ffname=${fname%%/*} ; \
		if [[ ! -f $$i ]] && [[ $$ffname != "demo" ]] ; then   \
			$(ECHO) "\n\t[ $$i ] not exist, warning!\n";   \
		fi;    \
	done


static:
	@$(ECHO) " \t Generate \t $(STATIC_JKLIB)"
	$(Q) $(AR) -r -o $(LIBDIR_PATH)/$(STATIC_JKLIB) $(buildin-files)
	$(Q) ln -sf $(LIBDIR_PATH)/$(STATIC_JKLIB) $(LIBDIR_PATH)/$(LINKSTATICJK)

dyn:
	@$(ECHO) " \t Generate \t $(DYNJKLIB)"
	$(Q) $(CC) -fPIC -shared -o $(LIBDIR_PATH)/$(DYNJKLIB) $(buildin-files)
	$(Q) ln -sf $(LIBDIR_PATH)/$(DYNJKLIB) $(LIBDIR_PATH)/$(LINKJK)

dep:
	@if [ ! -d $(HOME)/libs ]; then   \
	 $(ECHO) "No $(HOME)/libs directory, please svn co http://192.168.6.16/svn/application/binary/libs ${HOME}/libs";   \
	 exit 1;   \
	 fi


createdir:
	@if [ ! -f config.mk ]; then   \
		$(ECHO) "    No platform, please exec: "; \
		$(ECHO) "    make x86/hi3515/dm365/hi3535";  \
		exit 1; \
	fi
	@mkdir -p $(INSTALL_DIRS)/lib

install:
	@$(ECHO) "\t cp $(INSTALL_HEADERS) $(INSTALL_DIRS)/include/"
	$(Q) cp $(INSTALL_HEADERS) $(INSTALL_DIRS)/include/
	$(Q) cp $(INSTALL_LIBS) $(INSTALL_DIRS)/lib/

clean:
	@for i in $(filedirs-y) $(filedirs-d-y); do   \
		echo ""; \
		cd $$i; make clean; cd ..;   \
		echo ""; \
	done
	rm outlib/$(OS)/lib/* -rf

distclean: clean
	$(Q)rm -rf `find . -name ".obj*"`

help:
	@$(ECHO) "\t make x86/dm6446/dm365/hi3515/hi3518/hi3535"
	@$(ECHO) "\t make DEBUG [optional]"

x86:
	@$(ECHO) "OS=x86" > config.mk
amd64:
	@$(ECHO) "export OS=amd64" > config.mk

arm64:
	@$(ECHO) "export OS=arm64" > config.mk

dm6446:
	@$(ECHO) "OS=dm6446" > config.mk

dm365:
	@$(ECHO) "OS=dm365" > config.mk

rasp3:
	@$(ECHO) "OS=rasp3" > config.mk

hi3515:
	@$(ECHO) "OS=hi3515" > config.mk

hi3518:
	@$(ECHO) "OS=hi3518" > config.mk

hi3535:
	@$(ECHO) "OS=hi3535" > config.mk

DEBUG:
	@$(ECHO) "BVDEBUG=yes" >> config.mk



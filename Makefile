###
## Change it only when you add new file to compile
## other config please see config/...
## config.mk is generated by Makefile, so don't change it.

SHELL=/bin/bash

BASEDIR=$(shell pwd)

ECHO="echo -e"

include include.mk

sinclude config/config_all.mk

include common/Object.mk
obj-y += $(obj-cm-y:%=common/%)

CFLAGS += $(CFLAGS-y)
LDFLAGS += $(LDFLAGS-y)

predirs += $(predirs-y:%=common/%)
predirs += common/libconfig common/json common/crypto
ifeq ("$(CMEX)", "y")
predirs += common/ex
ifeq ("$(CMEXJSON)", "y")
predirs += common/ex/json/json
endif

obj-cpp-y += $(obj-cm-cpp-y:%=common/%)

endif

ifeq ("$(DEMO)", "y")
	include demo/Object.mk
	DEMOOBJS_y = $(obj-demo-y:%=demo/%)
	CPPDEMOOBJS_y = $(obj-demo-cpp-y:%=demo/%)
	predirs += demo
endif

ifeq ("$(VDEV)", "y")
	include vdev/Object.mk
	obj-y += $(obj-vdev-y:%=vdev/%)
	DEMOOBJS_y += $(obj-vdev-demo-y:%=vdev/%)
	predirs += vdev
endif

ifeq ("$(CODEC)", "y")
	include codec/Object.mk
	obj-y += $(obj-codec-y:%=codec/%)
	DEMOOBJS_y += $(obj-codec-demo-y:%=codec/%)
	predirs += codec
endif

ifeq ("$(QRCODE)", "y")
	include qrcode/Object.mk
	obj-y += $(obj-qrcode-y:%=qrcode/%)
	DEMOOBJS_y += $(obj-qrcode-demo-y:%=qrcode/%)
	predirs += qrcode
endif

ifeq ("$(RECORDSERVER)", "y")
	include recordserver/Object.mk
	obj-y += $(obj-recordserver-y:%=recordserver/%)
	DEMOOBJS_y += $(obj-recordserver-demo-y:%=recordserver/%)
	predirs += recordserver
endif

ifeq (x$(JKPROTOCOL), xy)
	include jkprotocol/Object.mk
	obj-y += $(obj-jkprotocol-y:%=jkprotocol/%)
	DEMOOBJS_y += $(obj-jkprotocol-y:%=jkprotocol/%)
	predirs += jkprotocol
endif

ifeq (x$(OPENAV), xy)
	include openav/Object.mk
	obj-cpp-y += $(obj-openav-y:%=openav/%)
	CPPDEMOOBJS_y += $(obj-openav-demo-y:%=openav/%)
	predirs += openav
ifeq (x$(OPENGL), xy)
	predirs += openav/gl
endif
endif

ifeq (x$(PROTOCOL), xy)
	include protocol/Object.mk
	obj-y += $(obj-protocol-y:%=protocol/%)
	DEMOOBJS_y += $(obj-protocol-y:%=protocol/%)
	predirs += protocol
endif

DEPS = $(obj-dep-y:%=$(OBJDIR)/%)
DEMOOBJS = $(patsubst %.c,%,$(DEMOOBJS_y))
CPPDEMOOBJS = $(patsubst %.cpp,%,$(CPPDEMOOBJS_y))
DEMOS = $(patsubst %.c,%-$(OS),$(DEMOOBJS_y))
CPPDEMOS = $(patsubst %.cpp,%-$(OS),$(CPPDEMOOBJS_y))

OBJS = $(obj-y:%=$(OBJDIR)/%)
CPPOBJS = $(obj-cpp-y:%=$(OBJDIR)/%)

all: generate_config createdir $(OBJS) $(CPPOBJS) static dyn $(DEMOOBJS) $(CPPDEMOOBJS)

$(OBJS):$(OBJDIR)/%.o:%.c
	@$(ECHO) "\t $(CC) \t $^"
	$(Q) $(CC) -o $@ -c $^ $(CFLAGS)

$(CPPOBJS):$(OBJDIR)/%.o:%.cpp
	@$(ECHO) "\t $(CXX) \t $^"
	$(Q) $(CXX) -o $@ -c $^ $(CXXFLAGS)

$(DEMOOBJS):%:%.c
	@$(ECHO) "\t $(CC) \t $^"
	$(Q) $(CC) -o $@-$(OS) $^ $(OBJS) $(DEMO_CFLAGS) $(LDFLAGS)

$(CPPDEMOOBJS):%:%.cpp
	@$(ECHO) "\t $(CXX) \t $^"
	$(Q) $(CXX) -o $@-$(OS) $^ $(OBJS) $(CPPOBJS) $(CFLAGS) $(LDFLAGS)

generate_config:
	@ [ -f $(CONFIG_FILE) ] && rm -rf $(CONFIG_FILE); \
		DATA=`date +%Y%m%d%H%M%S`; \
		GITVERSION=`./tools/setlocalversion`; \
		BUILD_GIT_VERSION=$$DATA.git-$$GITVERSION; \
		echo "# generated git version" >> $(CONFIG_FILE); \
		echo "#define BUILD_GIT_VERSION $$BUILD_GIT_VERSION" >> $(CONFIG_FILE)

static:
	@$(ECHO) " \t Generate \t $(STATIC_JKLIB)"
	$(Q) $(AR) -r -o $(LIBDIR_PATH)/$(STATIC_JKLIB) $(OBJS) $(CPPOBJS)
	$(Q) ln -sf $(LIBDIR_PATH)/$(STATIC_JKLIB) $(LIBDIR_PATH)/$(LINKSTATICJK)

dyn:
	@$(ECHO) " \t Generate \t $(DYNJKLIB)"
	$(Q) $(CC) -fPIC -shared -o $(LIBDIR_PATH)/$(DYNJKLIB) $(OBJS)
	$(Q) ln -sf $(LIBDIR_PATH)/$(DYNJKLIB) $(LIBDIR_PATH)/$(LINKJK)

createdir:
	@if [ ! -f config.mk ]; then   \
		$(ECHO) "    No platform, please exec: "; \
		$(ECHO) "    make x86/hi3515/dm365/hi3535";  \
		exit 1; \
	fi
	mkdir -p $(INSTALL_DIRS)/lib
	$(foreach d,$(predirs),$(shell mkdir -p $(OBJDIR)/$(d)))

install:
	@$(ECHO) "\t cp $(INSTALL_HEADERS) $(INSTALL_DIRS)/include/"
	$(Q) cp -vrf $(INSTALL_HEADERS) $(INSTALL_DIRS)/include/
	$(Q) cp -rvf $(INSTALL_LIBS) $(INSTALL_DIRS)/lib/

clean:
	rm -rf $(OBJS) $(CPPOBJS) $(DEMOS) $(CPPDEMOS)
	rm outlib/$(OS)/lib/* -rf

distclean: clean
	$(Q)rm -rf $(OBJDIR)

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

rk3308:
	@$(ECHO) "OS=rk3308" > config.mk

mips:
	@$(ECHO) "OS=mips" > config.mk

DEBUG:
	@$(ECHO) "BVDEBUG=yes" >> config.mk



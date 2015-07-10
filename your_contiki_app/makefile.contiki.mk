.PHONY: tests


CONTIKI_PROJECT=dot_firmware
all: $(CONTIKI_PROJECT) 

CONTIKI=../contiki
APPS = mqtt-service

CFLAGS += -DPROJECT_CONF_H=\"project-conf.h\" $(CPPUTEST_CFLAGS)


PROJECT_SOURCEFILES += \
	cli.c \
	network.c \
	cmd_table.c \
	mqtt_client.c \
	mqtt_buf.c \
	mqtt_topics.c \
	shared.c
	
ifndef MAKE_CONTIKI_LIB
PROJECT_SOURCEFILES += \
	slip-bridge.c
endif
	
	
CONTIKI_WITH_IPV6 = 1

ifdef MAKE_CONTIKI_LIB
CUSTOM_RULE_LINK=
endif

include $(CONTIKI)/Makefile.include

ifdef MAKE_CONTIKI_LIB
%.$(TARGET): %.co $(PROJECT_OBJECTFILES) $(PROJECT_LIBRARIES) contiki-$(TARGET).a
	$(TRACE_LD)
	$(Q)$(AR) rcs $@.a $(TARGET_STARTFILES) ${filter-out %.a,$^} ${filter %.a,$^}
	    
	
endif

tests: all
	$(MAKE) -f makefile.cpputest.mk all
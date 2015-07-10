.PHONY: tests


CONTIKI_PROJECT=your_contiki_app
all: $(CONTIKI_PROJECT) 

CONTIKI=../contiki
APPS = 

CFLAGS += -DPROJECT_CONF_H=\"project-conf.h\" $(CPPUTEST_CFLAGS)


PROJECT_SOURCEFILES += \
	your_contiki_app.c
	
ifndef MAKE_CONTIKI_LIB
PROJECT_SOURCEFILES += \
	
# Files that will be built in non testing binary
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

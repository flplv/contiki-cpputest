.PHONY: tests

ifeq (1,${V})
	SILENCE =
else
	SILENCE = @  
endif

ifndef TARGET
TARGET=native
endif

all:
	$(SILENCE)$(MAKE) -f makefile.contiki.mk TARGET=$(TARGET) V=$(V) all

tests: 
	$(SILENCE)$(MAKE) -f makefile.cpputest.mk all
	
tests_clean:
	$(SILENCE)$(MAKE) -f makefile.cpputest.mk clean
	
clean:
	$(SILENCE)$(MAKE) -f makefile.contiki.mk TARGET=$(TARGET) V=$(V) clean
	
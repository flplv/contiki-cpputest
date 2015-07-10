#Set this to @ to keep the makefile quiet
ifeq (1,${V})
	SILENCE =
else
	SILENCE = @  
endif

#---- Outputs ----#
COMPONENT_NAME = dot_firmware
TARGET_LIB = $(COMPONENT_NAME).native.a
CONTIKI_LIB = contiki-native.a
TEST_TARGET = $(COMPONENT_NAME)_tests

TEST_SRC_DIRS = \
	tests \
	tests/support 
		
INCLUDE_DIRS = \
  ../contiki/core \
  ../contiki/apps \
  ../contiki/cpu/native \
  ../contiki/platform/native \
  /usr/local/include/CppUTest \
  /usr/local/include/CppUTestExt \
  . \
  tests 
  
CPPUTEST_WARNINGFLAGS += -Wall 
CPPUTEST_WARNINGFLAGS += -Wextra

CPPUTEST_CFLAGS += -std=gnu99 
CPPUTEST_CFLAGS += -g3
CPPUTEST_CFLAGS += -O0 
CPPUTEST_CFLAGS += -DUNIT_TEST -Itests/support/

CPPUTEST_CPPFLAGS += -g3
CPPUTEST_CPPFLAGS += -O0 
CPPUTEST_CPPFLAGS += -DUNIT_TEST -Itests/support/
  
CPPUTEST_OBJS_DIR=obj_tests

CPPUTEST_LIB = /usr/local/lib/libCppUTest.a
CPPUTEST_LIB += /usr/local/lib/libCppUTestExt.a
LD_LIBRARIES += -lrt $(CPPUTEST_LIB)

CPPUTEST_CPPFLAGS += $(CPPUTEST_WARNINGFLAGS)
CPPUTEST_CFLAGS += $(CPPUTEST_C_WARNINGFLAGS)

#Helper Functions
get_src_from_dir  = $(wildcard $1/*.cpp) $(wildcard $1/*.cc) $(wildcard $1/*.c)
get_dirs_from_dirspec  = $(wildcard $1)
get_src_from_dir_list = $(foreach dir, $1, $(call get_src_from_dir,$(dir)))
__src_to = $(subst .c,$1, $(subst .cc,$1, $(subst .cpp,$1,$(if $(CPPUTEST_USE_VPATH),$(notdir $2),$2))))
src_to = $(addprefix $(CPPUTEST_OBJS_DIR)/,$(call __src_to,$1,$2))
src_to_o = $(call src_to,.o,$1)
src_to_d = $(call src_to,.d,$1)
src_to_gcda = $(call src_to,.gcda,$1)
src_to_gcno = $(call src_to,.gcno,$1)
time = $(shell date +%s)
delta_t = $(eval minus, $1, $2)
debug_print_list = $(foreach word,$1,echo "  $(word)";) echo;

#Derived
STUFF_TO_CLEAN += $(TEST_TARGET) $(TEST_TARGET).exe $(TARGET_LIB) $(TARGET_MAP)

TEST_SRC += $(call get_src_from_dir_list, $(TEST_SRC_DIRS)) $(TEST_SRC_FILES)
TEST_OBJS = $(call src_to_o,$(TEST_SRC))
STUFF_TO_CLEAN += $(TEST_OBJS)

MOCKS_SRC += $(call get_src_from_dir_list, $(MOCKS_SRC_DIRS))
MOCKS_OBJS = $(call src_to_o,$(MOCKS_SRC))
STUFF_TO_CLEAN += $(MOCKS_OBJS)

ALL_SRC = $(TEST_SRC) $(MOCKS_SRC)

RUN_TEST_TARGET = $(SILENCE) echo "Running $(TEST_TARGET)"; ./$(TEST_TARGET) $(CPPUTEST_EXE_FLAGS)

INCLUDES_DIRS_EXPANDED = $(call get_dirs_from_dirspec, $(INCLUDE_DIRS))
INCLUDES += $(foreach dir, $(INCLUDES_DIRS_EXPANDED), -I$(dir))
MOCK_DIRS_EXPANDED = $(call get_dirs_from_dirspec, $(MOCKS_SRC_DIRS))
INCLUDES += $(foreach dir, $(MOCK_DIRS_EXPANDED), -I$(dir))

CPPUTEST_CPPFLAGS +=  $(INCLUDES)

DEP_FILES = $(call src_to_d, $(ALL_SRC))
STUFF_TO_CLEAN += $(DEP_FILES)
STUFF_TO_CLEAN += $(MAP_FILE) cpputest_*.xml junit_run_output

# We'll use the CPPUTEST_CFLAGS etc so that you can override AND add to the CppUTest flags
CFLAGS = $(CPPUTEST_CFLAGS) 
CPPFLAGS = $(CPPUTEST_CPPFLAGS)
LDFLAGS = $(CPPUTEST_LDFLAGS) $(CPPUTEST_ADDITIONAL_LDFLAGS)

DEP_FLAGS=-MMD -MP

.PHONY: all
all: start $(TEST_TARGET)
	$(RUN_TEST_TARGET)

.PHONY: start
start: $(TEST_TARGET)
	$(SILENCE)START_TIME=$(call time)

.PHONY: all_no_tests
all_no_tests: $(TEST_TARGET)

$(TARGET_LIB): FORCE
	$(MAKE) -f makefile.contiki.mk CPPUTEST_CFLAGS="$(CFLAGS)" TARGET=native MAKE_CONTIKI_LIB=1 V=$(V) all

FORCE:

TEST_DEPS = $(TEST_OBJS) $(MOCKS_OBJS) $(TARGET_LIB) $(USER_LIBS)
test-deps: $(TEST_DEPS)

$(TEST_TARGET): $(TEST_DEPS)
	@echo Linking $@
	$(SILENCE)$(CXX) -o $@ $^ $(LD_LIBRARIES) $(LDFLAGS) $(CONTIKI_LIB) 
	
test: $(TEST_TARGET)
	$(RUN_TEST_TARGET) | tee $(TEST_OUTPUT)

vtest: $(TEST_TARGET)
	$(RUN_TEST_TARGET) -v  | tee $(TEST_OUTPUT)

$(CPPUTEST_OBJS_DIR)/%.o: %.cc
	@echo compiling $(notdir $<)
	$(SILENCE)mkdir -p $(dir $@)
	$(SILENCE)$(COMPILE.cpp) $(DEP_FLAGS) $(CPPFLAGS) $(OUTPUT_OPTION) $<

$(CPPUTEST_OBJS_DIR)/%.o: %.cpp
	@echo compiling $(notdir $<)
	$(SILENCE)mkdir -p $(dir $@)
	$(SILENCE)$(COMPILE.cpp) $(DEP_FLAGS) $(CPPFLAGS) $(OUTPUT_OPTION) $<

$(CPPUTEST_OBJS_DIR)/%.o: %.c
	@echo compiling $(notdir $<)
	$(SILENCE)mkdir -p $(dir $@)
	$(SILENCE)$(COMPILE.c) $(DEP_FLAGS) $(CFLAGS) $(OUTPUT_OPTION) $<

.PHONY: clean
clean:
	@echo Making clean
	$(SILENCE)$(RM) -rf $(STUFF_TO_CLEAN) $(CPPUTEST_OBJS_DIR)
	$(SILENCE)$(MAKE) -f makefile.contiki.mk TARGET=native MAKE_CONTIKI_LIB=1 V=$(V) clean
	
	
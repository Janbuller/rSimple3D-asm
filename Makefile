# Project/executable name
PROJECT_NAME := rSimple3D

# Libraries to include with `pkg-config`
LIBRARIES := raylib

# Directories to use
BUILD_DIR := ./build
SRC_DIRS := ./src
INC_DIR := ./include

# Customizable CFLAGS and LDFLAGS
CFLAGS := -ansi -pedantic -pedantic-errors -Wall -Wextra -O3
LDFLAGS := -no-pie



SRCS := $(shell find $(SRC_DIRS) -name '*.c' -or -name '*.s')
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

INC_DIRS := $(shell find $(INC_DIR) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

CPPFLAGS := $(INC_FLAGS) -MMD -MP

CFLAGS := $(CFLAGS) $(shell pkg-config --cflags $(LIBRARIES))
LDFLAGS := $(LDFLAGS) $(shell pkg-config --libs $(LIBRARIES)) -lm

$(BUILD_DIR)/$(PROJECT_NAME): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.s.o: %.s
	mkdir -p $(dir $@)
	nasm -felf64 $< -o $@

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)

-include $(DEPS)

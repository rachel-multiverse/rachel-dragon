# Rachel Dragon 32/CoCo Client Makefile

ASM6809 ?= asm6809
LWASM ?= lwasm

BUILD_DIR = build
SRC_DIR = src

TARGET = $(BUILD_DIR)/rachel.bin

.PHONY: all clean

all: $(BUILD_DIR) $(TARGET)
	@echo "Built: $(TARGET)"

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(TARGET): $(SRC_DIR)/main.asm $(SRC_DIR)/*.asm $(SRC_DIR)/net/*.asm
	cd $(SRC_DIR) && $(ASM6809) -o ../$(TARGET) main.asm 2>/dev/null || \
	$(LWASM) --raw -o ../$(TARGET) main.asm

clean:
	rm -rf $(BUILD_DIR)

# ============================================================
# the-realm-of-loss2 构建
# gcc + SDL3 + Vulkan  ·  macOS/Arch Linux  ·  中文路径友好
# gmake / gmake run / gmake clean / gmake debug / gmake info
# 要求：GNU Make 4.0+（macOS 用 brew 的 gmake，Arch 默认就是）
# ============================================================

BUILD      := build
SRC        := 源码
INC        := 源码/头文件
TARGET_EXE := $(BUILD)/the-realm-of-loss2

# ── 编译器 ──
CC  := $(firstword $(shell command -v gcc-16 gcc-15 gcc clang 2>/dev/null))
CXX := $(firstword $(shell command -v g++-16 g++-15 g++ clang++ 2>/dev/null))

# ── flags ──
OPT  ?= -O2
WARN  = -Wall -Wextra
STD   = -std=c17

SDL3_CF := $(shell pkg-config --cflags sdl3 2>/dev/null)
SDL3_LD := $(shell pkg-config --libs   sdl3 2>/dev/null)

# Vulkan：pkg-config 优先，否则扫标准路径（macOS/Arch 都覆盖）
VK_CF   := $(shell pkg-config --cflags vulkan 2>/dev/null)
VK_LD   := $(shell pkg-config --libs   vulkan 2>/dev/null)
ifeq ($(VK_CF),)
  VK_HOME := $(HOME)/VulkanSDK
  VK_INC  := $(wildcard $(VK_HOME)/*/macOS/include) \
             $(wildcard $(VK_HOME)/*/Linux/include) \
             $(wildcard /opt/homebrew/include/vulkan/..) \
             $(wildcard /usr/local/include/vulkan/..) \
             $(wildcard /usr/include/vulkan/..)
  VK_INC  := $(sort $(foreach d,$(VK_INC),$(if $(wildcard $(d)/vulkan/vulkan.h),$(d))))
  VK_LIB  := $(firstword $(wildcard $(VK_HOME)/*/macOS/lib) \
                         $(wildcard $(VK_HOME)/*/Linux/lib) \
                         $(wildcard /opt/homebrew/lib) \
                         $(wildcard /usr/local/lib) \
                         $(wildcard /usr/lib))
  VK_CF   := $(addprefix -I,$(VK_INC))
  VK_LD   := -lvulkan
  ifneq ($(VK_LIB),)
    VK_LD  += -L$(VK_LIB) -Wl,-rpath,$(VK_LIB)
  endif
endif

CFLAGS   = $(OPT) $(WARN) $(STD) -I$(SRC) -I$(INC) $(SDL3_CF) $(VK_CF)
LDFLAGS  = $(SDL3_LD) $(VK_LD)

# ── 源文件 ──
SRCS := $(shell find "$(SRC)" -type f -name '*.c')
OBJS := $(patsubst $(SRC)/%.c,$(BUILD)/%.o,$(SRCS))

# ── 最顶部放默认目标（变量必须在 all: 之前定义好）──
.PHONY: all run debug clean info FORCE
all: compile_flags.txt $(TARGET_EXE)

# ── clangd 配置（make 时自动同步）──
compile_flags.txt: FORCE
	@echo "$(CFLAGS)" | tr ' ' '\n' | grep . > $@

# ── 编译规则（foreach/eval，中文路径稳吃）──
define GEN_RULE
$(1): $(patsubst $(BUILD)/%.o,$(SRC)/%.c,$(1))
	@echo "CC  $$<"
	@mkdir -p $$(dir $$@)
	$$(CC) $$(CFLAGS) -c $$< -o $$@
endef
$(foreach o,$(OBJS),$(eval $(call GEN_RULE,$(o))))

# ── 链接 ──
$(TARGET_EXE): $(OBJS)
	@echo "LD  $@"
	@mkdir -p $(dir $@)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

# ── 其他目标 ──
run: $(TARGET_EXE)
	./$(TARGET_EXE)

debug: $(TARGET_EXE)
	lldb ./$(TARGET_EXE) 2>/dev/null || gdb ./$(TARGET_EXE)

clean:
	rm -rf $(BUILD) compile_flags.txt

info:
	@echo "CC      = $(CC)"
	@echo "CFLAGS  = $(CFLAGS)"
	@echo "LDFLAGS = $(LDFLAGS)"
	@echo "SRCS    = $(SRCS)"
	@echo "OBJS    = $(OBJS)"

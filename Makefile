BUSYBOX_DIR=$(realpath deps/busybox)
LINUX_DIR=$(realpath deps/linux)

BUSYBOX=$(BUSYBOX_DIR)/busybox

ROOTFS_BUILD_DIR=$(realpath build)/rootfs
ROOTFS_BUILD=$(realpath build)/initramfs.cpio.gz

BUSYBOX_ROOTFS=$(ROOTFS_BUILD_DIR)/bin/busybox

# Change this depending on ARM vs ARM64
ARCH ?= arm64
CROSS_COMPILE ?= aarch64-linux-gnu-

# Kernel output image (adjust for arm64 if needed)
LINUX_NAME=Image.gz
LINUX=$(realpath build)/$(LINUX_NAME)





ALL: .ROOTFS $(LINUX)

# Build busybox
$(BUSYBOX):
	ln  busybox.config $(BUSYBOX_DIR)/.config || true
	$(MAKE) -C "$(BUSYBOX_DIR)" -j ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)

$(BUSYBOX_ROOTFS): $(BUSYBOX) $(ROOTFS_BUILD_DIR)
	$(MAKE) -C "$(BUSYBOX_DIR)" CONFIG_PREFIX=$(ROOTFS_BUILD_DIR) \
		ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) install

$(ROOTFS_BUILD_DIR):
	mkdir -p $(ROOTFS_BUILD_DIR)
	cp -r rootfs/* $(ROOTFS_BUILD_DIR)
	chmod +x $(ROOTFS_BUILD_DIR)/init

$(ROOTFS_BUILD): $(BUSYBOX_ROOTFS)
	cd $(ROOTFS_BUILD_DIR) ; find . | cpio -H newc -o | gzip > ../initramfs.cpio.gz

$(LINUX):
	ln  linux.config $(LINUX_DIR)/.config || true
	$(MAKE) -C "$(LINUX_DIR)" ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)
	cp $(LINUX_DIR)/arch/$(ARCH)/boot/$(LINUX_NAME) $(LINUX)

.ROOTFS: $(ROOTFS_BUILD)

linux_config:
	$(MAKE) -C "$(LINUX_DIR)" menuconfig ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)
	cp "$(LINUX_DIR)"/.config linux.config
busy_config:
	$(MAKE) -C "$(BUSYBOX_DIR)" menuconfig
	cat "$(BUSYBOX_DIR)/.config" > busybox.config



clean:
	rm -rf $(ROOTFS_BUILD_DIR) $(ROOTFS_BUILD) $(LINUX)

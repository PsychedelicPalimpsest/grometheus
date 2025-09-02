


BUSYBOX_DIR=$(realpath deps/busybox)
LINUX_DIR=$(realpath deps/linux)

BUSYBOX=$(BUSYBOX_DIR)/busybox

ROOTFS_BUILD_DIR=$(realpath build)/rootfs
ROOTFS_BUILD=$(realpath build)/initramfs.cpio.gz


BUSYBOX_ROOTFS=$(ROOTFS_BUILD_DIR)/bin/rootfs


LINUX=$(realpath build)/bzImage


ALL: .ROOTFS $(LINUX)


# Build busybox
$(BUSYBOX):
	@-ln busybox.config deps/busybox/.config || true
	$(MAKE) -C "$(BUSYBOX_DIR)" -j



$(BUSYBOX_ROOTFS): $(BUSYBOX) $(ROOTFS_BUILD_DIR)
	$(MAKE) -C "$(BUSYBOX_DIR)" CONFIG_PREFIX=$(ROOTFS_BUILD_DIR) install


$(ROOTFS_BUILD_DIR):
	mkdir -p $(ROOTFS_BUILD_DIR)
	cp -r rootfs/* $(ROOTFS_BUILD_DIR)

	chmod +x rootfs/init

$(ROOTFS_BUILD): $(BUSYBOX_ROOTFS) $(ROOTFS_BUILD)
	cd $(ROOTFS_BUILD_DIR) ; find . | cpio -H newc -o | gzip > ../initramfs.cpio.gz


$(LINUX):

	@-ln linux.config deps/linux/.config || true
	$(MAKE) -C "$(LINUX_DIR)" 
	
	cp "$(LINUX_DIR)"/arch/x86/boot/bzImage $(LINUX)



.ROOTFS: $(ROOTFS_BUILD)



clean:
	#$(MAKE) -C "$(BUSYBOX_DIR)" clean
	rm -rf $(ROOTFS_BUILD_DIR) $(LINUX)

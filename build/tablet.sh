qemu-system-x86_64 \
  -kernel bzImage \
  -initrd initramfs.cpio.gz \
  -append "console=ttyS0 console=tty0" \
  -serial mon:stdio \
  -device usb-ehci \
  -device usb-tablet \
  -enable-kvm \
  -cpu host

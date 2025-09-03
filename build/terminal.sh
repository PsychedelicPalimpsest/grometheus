# qemu-system-x86_64 -kernel bzImage -initrd initramfs.cpio.gz -append "console=ttyS0 rdinit=/init" -nographic -enable-kvm -cpu host
zcat Image.gz > Image

qemu-system-aarch64 \
  -machine virt,virtualization=on \
  -cpu cortex-a57 \
  -m 1024 \
  -kernel Image \
  -initrd initramfs.cpio.gz \
  -append "console=ttyAMA0 init=/init rdinit=/init" \
  -nographic -accel tcg,thread=multi 

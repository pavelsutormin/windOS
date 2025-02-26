OBJECTS = loader.o kmain.o drivers/io/io.o drivers/frame_buffer/frame_buffer.o drivers/serial_port/serial_port.o memory/segmentation/gdt.o memory/segmentation/segments.o drivers/interrupts/keyboard.o drivers/interrupts/interrupt_handlers.o drivers/interrupts/interrupts.o drivers/interrupts/pic.o drivers/interrupts/idt.o utils/common/common.o memory/paging/paging.o memory/heap/kheap.o drivers/interrupts/isr.o utils/log.o user_mode/user_mode.o drivers/interrupts/interrupt_enabler.o

    CC = gcc
    CFLAGS = -m32 -nostdlib -fno-builtin -fno-stack-protector \
         -Wno-unused -nostartfiles -nodefaultlibs -Wall -Wextra -Werror -c -masm=intel
    LDFLAGS = -T link.ld -melf_i386
    AS = nasm
    ASFLAGS = -f elf

    all: kernel.elf

    kernel.elf: $(OBJECTS)
	ld $(LDFLAGS) $(OBJECTS) -o kernel.elf

    windOS.iso: kernel.elf
	cp kernel.elf iso/boot/kernel.elf
	genisoimage -R                              \
                    -b boot/grub/stage2_eltorito    \
                    -no-emul-boot                   \
                    -boot-load-size 4               \
                    -A os                           \
                    -input-charset utf8             \
                    -quiet                          \
                    -boot-info-table                \
                    -o windOS.iso                       \
                    iso

    run: windOS.iso
	bochs -f bochsrc.txt -q
	

    %.o: %.c
	$(CC) $(CFLAGS)  $< -o $@

    %.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

    clean:
	rm -rf *.o kernel.elf windOS.iso

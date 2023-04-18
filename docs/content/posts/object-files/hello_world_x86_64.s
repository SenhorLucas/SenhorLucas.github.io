.global _start
.data
hello_world:
    .ascii "Hello world!\n"
    hello_world_len = . - hello_world

.text
_start:
    mov $4, %eax
    mov $1, %ebx
    mov $hello_world, %ecx
    mov $hello_world_len, %edx
    int $0x80

    mov $1, %al
    mov $0, %ebx
    int $0x80

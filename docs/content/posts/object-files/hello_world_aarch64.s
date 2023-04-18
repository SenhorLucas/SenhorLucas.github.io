/* Compile with:
 * aarch64-linux-gnu-as -o hello_world_arm64 hello_world_arm64.s
**/

.global _start

.text
_start:
    mov  w7, #4
    mov  x0, #1
    ldr  x1, =hello_world
    ldr  x2, =hello_world_len

    svc 0

    mov w7, #1
    mov x0, #0
    svc 0

.data
hello_world:       .ascii "Hello world!\n"
hello_world_len = . - hello_world

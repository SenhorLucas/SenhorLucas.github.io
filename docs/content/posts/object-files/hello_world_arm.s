/* Compile with:
 * arm-none-eabi-as -o hello_world_arm32 hello_world_arm32.s
**/

.global _start

.text
_start:
    mov  r7, #4
    mov  r0, #1
    ldr  r1, =hello_world
    ldr  r2, =hello_world_len

    svc 0

    mov r7, #1
    mov r0, #0
    svc 0

.data
hello_world:       .ascii "Hello world!\n"
hello_world_len = . - hello_world

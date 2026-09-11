        .global _start

        .text
_start:
        # exit(0)
        mov     $60, %rax               # system call 60 is exit
        mov     $42, %rdi                # return code 0
        syscall                         # invoke operating system to exit


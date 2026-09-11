# C, Pascal, Assembly, Object Files and System Calls

In this lab we will look at very small programs written in:

* assembly
* C
* Pascal
* a mixture of C and assembly

The programs themselves are intentionally trivial.

That is the point.

When the program does almost nothing, it becomes much easier to see what the compiler, assembler, linker, libraries and operating system are doing.

The main questions of this lab are:

1. What is an object file?
2. What does the assembler produce?
3. What does the compiler produce?
4. What does the linker do?
5. What symbols exist inside object files?
6. What machine instructions are actually present in an executable?
7. What is the difference between a function call and a system call?
8. Which programs depend on `libc`?
9. What happens before and after our own code runs?
10. What exactly does `make` do?

---

# Repository contents

The repository contains several very small examples:

```text
exit/
exit64/
exit_c/
exit_pas/

write32/
write64/
write_c/
write_pas/

mix/
```

We are **not going to start by running `make`**.

The purpose of the Makefiles in the beginning of this lab is to tell you which commands to execute.

You will read those commands and type them yourself.

Only after you understand the individual steps will you may use `make`.

---

# The method

For each directory, work slowly.

The general procedure is:

```text
read source
     |
     v
read Makefile
     |
     v
execute first command by hand
     |
     v
ls
     |
     v
inspect whatever new file appeared
     |
     v
execute next command by hand
     |
     v
ls
     |
     v
inspect executable
     |
     v
run it
     |
     v
ldd
     |
     v
objdump
     |
     v
strace
```

Do **not** simply copy all commands at once.

Pay attention to what each command creates.

After every build command, run:

```sh
ls -l
```

and/or

```sh
ls -lh
```

and look at what changed.

---

# Part 1 — Start with an assembly program

Enter one of the assembly directories.

For example:

```sh
cd exit64
```

Look at the files:

```sh
ls -l
```

Read the assembly source:

```sh
cat exit.s
```

Then read the Makefile:

```sh
cat makefile
```

Do **not** run `make`.

You should see commands for assembling and linking.

Execute the assembler command yourself.

It will be something similar to:

```sh
as -o exit.o exit.s
```

Immediately run:

```sh
ls -lh
```

Something new has appeared:

```text
exit.o
```

Stop here.

Do not link it yet.

You have just created an **object file** out of an assembly source.

---

# Part 2 — Inspect the object file immediately

Before doing anything else, inspect the new object file.

First:

```sh
file exit.o
```

Then:

```sh
nm exit.o
```

Read some parts of:

```sh
man nm
```

Try to understand what symbols are present.

For example, you may see `_start`.

Also disassemble the object file:

```sh
objdump -d exit.o
```

Compare what you see with:

```sh
cat exit.s
```

You have assembly source.

The assembler translated that source into machine code inside an object file.

`objdump` can translate those machine-code bytes back into an assembly representation.

The spelling may be slightly different.

For example, your source may contain:

```asm
mov $60, %rax
```

while the disassembler may print:

```asm
mov $0x3c, %rax
```

`60` decimal and `0x3c` hexadecimal are the same number.

Also notice the hexadecimal bytes printed by `objdump`.

Those bytes are the actual machine-code representation stored in the file. That is the actual program that CPU executes.

---

# Part 3 — Link the object file

Now return to the Makefile:

```sh
cat makefile
```

Find the linker command.

Run it yourself.

For example:

```sh
ld -o exit exit.o
```

Now:

```sh
ls -l
```

Another file has appeared:

```text
exit
```

You now have:

```text
exit.s    source
exit.o    object file
exit      executable
```

This is the transformation you just performed:

```text
exit.s
   |
   | as
   v
exit.o
   |
   | ld
   v
exit
```

The assembler did not create the final executable.

The linker took the object file and created the executable.

---

# Part 4 — Inspect and run the executable

First ask what kind of file it is:

```sh
file exit
```

Inspect its symbols:

```sh
nm exit
```

Now disassemble the final executable:

```sh
objdump -d ./exit
```

Save the disassembly:

```sh
objdump -d ./exit > disassembly.txt
```

Open it:

```sh
less disassembly.txt
```

Find `_start`.

Compare the instructions there with the original source:

```sh
cat exit.s
```

For these tiny assembly examples, you should be able to recognize essentially every instruction from your source in the final executable.

Now run it:

```sh
./exit
```

If this program demonstrates an exit status, ask the shell what exit status it received:

```sh
echo $?
```

---

# Part 5 — Does it need shared libraries?

Run:

```sh
ldd ./exit
```

Read some parts of:

```sh
man ldd
```

Save the result:

```sh
ldd ./exit > ldd.txt 2>&1
```

Why `2>&1`?

Because a message such as:

```text
not a dynamic executable
```

may be written to standard error rather than standard output.

Look at `ldd.txt`.

This tiny assembly program communicates directly with Linux using system calls.

It does not need the C standard library in order to run.

This is an important observation:

**A Linux program does not automatically need libc.**

---

# Part 6 — Watch it run with `strace`

Read:

```sh
man strace
```

Then:

```sh
strace ./exit
```

Save the trace:

```sh
strace -o strace.txt ./exit
```

Count its lines:

```sh
wc -l strace.txt
```

Open it:

```sh
cat strace.txt
```

or:

```sh
less strace.txt
```

Look at what the program actually asks the kernel to do.

A tiny handwritten assembly program should have a very small trace.

Keep:

```text
ldd.txt
strace.txt
disassembly.txt
```

You will commit them later.

---

# Part 7 — Continue with the other assembly examples

Now repeat the same process for:

```text
exit/
exit64/
write32/
write64/
```

For **every directory**:

1. `cd` into it.
2. Run `ls -l`.
3. Read the `.s` file.
4. Read the Makefile.
5. Do not run `make`.
6. Execute the assembler command manually.
7. Run `ls -l`.
8. Stop and inspect the new `.o` file.
9. Run `file` on it.
10. Run `nm` on it.
11. Run `objdump -d` on it.
12. Execute the linker command manually.
13. Run `ls -l`.
14. Inspect the executable with `file` and `nm`.
15. Run it.
16. Run `ldd`.
17. Save the `ldd` output.
18. Disassemble the executable and save the output.
19. Run `strace`.
20. Save the trace.
21. Count its lines.

For the 32-bit programs, notice that the commands are different.

You may see:

```sh
as --32 -o exit.o exit.s
```

and:

```sh
ld -m elf_i386 -o exit exit.o
```

Look at those options.

Think about why they are necessary.

Also compare the actual system-call instructions.

The 32-bit examples use something such as:

```asm
int $0x80
```

while the 64-bit examples use:

```asm
syscall
```

---

# Part 8 — The `write` examples

The `write32` and `write64` examples are especially useful with `strace`.

Their assembly source contains code which asks Linux to write bytes to standard output.

Look at the source first.

Then later look at the saved `strace` output.

You should see a system call named:

```text
write
```

The exact assembly instructions used to request that operation differ between 32-bit and 64-bit Linux.

But `strace` shows the operation at the system-call level.

This is our first connection between:

```text
assembly instructions
```

and:

```text
Linux system calls
```

---

# Part 9 — Now examine the C examples

Go to:

```sh
cd exit_c
```

Look around:

```sh
ls -l
```

Read the source:

```sh
cat exit.c
```

Read the Makefile:

```sh
cat makefile
```

Again:

**do not run `make` yet.**

The Makefile may contain a command such as:

```sh
cc -o exit exit.c
```

That one command hides several build stages.

For this lab, first create an object file explicitly:

```sh
cc -c exit.c -o exit.o
```

Now immediately:

```sh
ls -l
```

Stop.

Inspect the object file:

```sh
file exit.o
nm exit.o
objdump -d exit.o
```

Read the `nm` output carefully.

A compiler also produces object files.

The source language was C rather than assembly, but the linker eventually works with object files.

Now link the object file:

```sh
cc -o exit exit.o
```

Then:

```sh
ls -l
```

Run:

```sh
file exit
nm exit
objdump -d ./exit > disassembly-dynamic.txt
./exit
echo $?
```

Then:

```sh
ldd ./exit > ldd-dynamic.txt 2>&1
```

and:

```sh
strace -o strace-dynamic.txt ./exit
wc -l strace-dynamic.txt
```

Open those files and look at them.

---

# Part 10 — What did `cc` do?

Compare this:

```sh
cc -c exit.c -o exit.o
```

with:

```sh
cc -o exit exit.o
```

The first command compiles the C source and produces an object file.

The second command performs the final linking.

Notice that we use `cc` for the final C linking step rather than bare `ld`.

A normal C program needs startup code and usually libraries.

The compiler driver knows what should be supplied to the linker.

It eventually invokes the linker, but it does some work for you.

This is one reason commands such as:

```sh
cc -o exit exit.c
```

can make the build process appear simpler than it actually is.

---

# Part 11 — Build the static C version

Look at the Makefile again.

You may see:

```sh
cc -static -o exitStatic exit.c
```

Execute it manually.

Then:

```sh
ls -l
```

Compare the sizes:

```sh
ls -lh exit exitStatic
```

Now inspect the static executable too:

```sh
file exitStatic
nm exitStatic
objdump -d ./exitStatic > disassembly-static.txt
ldd ./exitStatic > ldd-static.txt 2>&1
strace -o strace-static.txt ./exitStatic
wc -l strace-static.txt
```

Run it as well.

Compare:

```text
exit
exitStatic
```

They were created from the same C source.

But they are not the same kind of executable.

Look at:

* their sizes
* their `ldd` output
* their disassembly
* their `strace` output

Do not try to understand every instruction in a large disassembly.

Look at the difference in scale.

---

# Part 12 — Repeat for `write_c`

Perform the same process in:

```text
write_c/
```

First read everything.

Then create the object file manually.

Immediately inspect it.

Then link it.

Then inspect and run the executable.

Save:

```text
ldd-dynamic.txt
ldd-static.txt

strace-dynamic.txt
strace-static.txt

disassembly-dynamic.txt
disassembly-static.txt
```

When looking through the trace of the dynamically linked C program, find:

```text
write
```

Your C source says:

```c
printf(...)
```

but eventually something must ask the Linux kernel to send bytes to standard output.

You should find such a system call in the trace.

---

# Part 13 — Compare assembly and C

At this point compare:

```text
write64/
write_c/
```

Both ultimately print something.

But their executables are very different.

Compare their sizes:

```sh
ls -lh
```

Compare:

```text
nm
objdump -d
ldd
strace
```

The handwritten assembly program has very little machinery around your code.

A normal dynamically linked C program has runtime startup code and a dynamic loader.

Before `main()` begins, various things may already need to happen.

You may see system calls such as:

```text
execve
openat
read
mmap
mprotect
close
write
exit_group
```

The exact output depends on your system.

The important question is why a tiny C program can result in many more operations than a tiny handwritten assembly program.

---

# Part 14 — Pascal

Now examine:

```text
exit_pas/
write_pas/
```

Read the source.

For example:

```sh
cat exit.pas
```

If there is a Makefile, read it first.

Again, do not initially run `make`.

Execute the compiler command yourself.

For example:

```sh
fpc exit.pas
```

Then immediately:

```sh
ls -l
```

Look carefully at what files appeared.

Inspect them with tools you already know.

For the executable:

```sh
file exit
nm exit
objdump -d ./exit > disassembly.txt
ldd ./exit > ldd.txt 2>&1
strace -o strace.txt ./exit
wc -l strace.txt
```

Run it:

```sh
./exit
echo $?
```

For the writing example:

```sh
./write
```

Do the same investigation.

Compare Pascal with both C and assembly.

Do not assume that all compiled languages produce executables with the same runtime dependencies.

Observe first.

Also observe file sizes with `ls -lh`. 

---

# Part 15 — A second Pascal executable

The `exit_pas` Makefile may contain two compiler commands:

```sh
fpc exit.pas
fpc -XX -oexit2 exit.pas
```

Execute the first command manually:

```sh
fpc exit.pas
```

Then:

```sh
ls -lh
```

Now execute the second command:

```sh
fpc -XX -oexit2 exit.pas
```

And again:

```sh
ls -lh
```

Compare:

```sh
ls -lh exit exit2
```

For an exact comparison:

```sh
stat -c '%n %s bytes' exit exit2
```

Both programs came from exactly the same Pascal source.

Run both:

```sh
./exit
echo $?

./exit2
echo $?
```

Do they behave differently?

Now compare their sizes.

Why are they different?

For now, simply observe this.

We will discuss the reason later.

Inspect both executables:

```sh
ldd ./exit > ldd.txt 2>&1
ldd ./exit2 > ldd-smart.txt 2>&1

objdump -d ./exit > disassembly.txt
objdump -d ./exit2 > disassembly-smart.txt

strace -o strace.txt ./exit
strace -o strace-smart.txt ./exit2
```

Count the traces:

```sh
wc -l strace.txt strace-smart.txt
```

Save all these results.

---

# Part 16 — The mixed C and assembly example

Finally go to:

```sh
cd mix
```

This directory is especially important.

It contains:

```text
main.c
add.s
Makefile
```

Read all three:

```sh
cat main.c
cat add.s
cat Makefile
```

Again:

**do not run `make`.**

Look at the individual commands in the Makefile.

Execute the first compilation command yourself:

```sh
gcc -c main.c
```

Then immediately:

```sh
ls -l
```

You should now have:

```text
main.o
```

Stop.

Inspect it:

```sh
file main.o
nm main.o
objdump -d main.o
```

Pay special attention to the `nm` output.

Look for:

```text
add
```

The C source declares:

```c
extern long add(long, long);
```

But there is no implementation of `add` in `main.c`.

What does `nm` say about it?

Look up the meaning of the letter printed beside it.

---

# Part 17 — Create the assembly object file

Now execute the next command from the Makefile:

```sh
gcc -c add.s
```

Then:

```sh
ls -l
```

A second object file has appeared:

```text
add.o
```

Again, stop before linking.

Inspect it:

```sh
file add.o
nm add.o
objdump -d add.o
```

Look for:

```text
add
```

Compare the `nm` output from:

```sh
nm main.o
```

with:

```sh
nm add.o
```

You should discover something very important.

Conceptually:

```text
main.o                         add.o

        U add   ------------>   T add
```

I say: Uzuma ---> Talisa.

One object file says:

> I need a symbol named `add`.

The other says:

> I provide a symbol named `add`.

Neither object file is the complete program.

---

# Part 18 — Link the mixed program

Now execute the final command from the Makefile:

```sh
gcc -o example main.o add.o
```

Then:

```sh
ls -l
```

Now the linker has created:

```text
example
```

Run:

```sh
nm example
```

Then:

```sh
./example
```

You should get:

```text
42
```

The C compiler did not know how `add` was implemented.

The assembly source did not know anything about `main`.

The linker connected the two object files.

This is one of the main purposes of a linker.

---

# Part 19 — How can C call assembly?

The assembly code contains something like:

```asm
.globl add

add:
        mov %rdi, %rax
        add %rsi, %rax
        ret
```

The C code calls:

```c
add(20, 22)
```

On x86-64 Linux, the calling convention specifies where arguments and return values go.

For integer arguments here:

```text
first argument   -> %rdi
second argument  -> %rsi
return value     -> %rax
```

The C compiler follows that convention.

The assembly code follows the same convention.

Therefore they can communicate.

We may have written:

```asm
.type add, @function
```

But it is not necessary, so we did not. To keep the examples simple.

The processor does not need ELF metadata telling it:

```text
this symbol is a function
```

It needs an address containing instructions which obey the calling convention.

---

# Part 20 — Disassemble the mixed executable

Now:

```sh
objdump -d ./example > disassembly.txt
```

Open it:

```sh
less disassembly.txt
```

Search for:

```sh
grep -n add disassembly.txt
```

Find the `add` code.

Compare it with:

```sh
cat add.s
```

You should recognize:

```asm
mov %rdi, %rax
add %rsi, %rax
ret
```

Also look for the code which calls `add`.

You now have several views of the same relationship:

```text
main.c
    |
    v
main.o
    U add
    |
    |              add.o
    |              T add
    |                |
    +------ linker --+
             |
             v
          example
             |
             v
         objdump
             |
             v
     call to add + add code
```

Save the disassembly.

---

# Part 21 — `strace` the mixed executable

Run:

```sh
strace -o strace.txt ./example
```

Then:

```sh
wc -l strace.txt
```

Look through it.

Search for:

```sh
grep add strace.txt
```

Do you find a system call named `add`?

You should not.

But you know for certain that `add` executed.

You just saw its code in the executable.

You can even see the call to it in the disassembly.

Now search for:

```sh
grep write strace.txt
```

You should find a `write` system call associated with producing the output.

This shows a crucial distinction.

The program does something approximately like:

```text
main()
   |
   +----> add()
   |
   +----> printf()
               |
               +----> write(...)
                           |
                           v
                      Linux kernel
```

`add()` is an ordinary function call.

`printf()` is an ordinary user-space library function.

`write()` is a system call.

`strace` shows system calls.

It does **not** show every function call made by the program.

Therefore:

```text
objdump shows the call to add
```

but:

```text
strace does not show add
```

At the same time:

```text
strace shows write
```

because `write` crosses from user space into the kernel.

Remember:

```text
function call != system call
```

---

# Part 22 — What the four tools show

During this lab you have used four important tools.

They answer different questions.

```text
nm
```

shows symbols contained in object files and executables.

```text
objdump -d
```

shows machine instructions by disassembling machine code.

```text
ldd
```

shows dynamic shared-library dependencies.

```text
strace
```

shows system calls performed while a program runs.

Do not confuse these different views.

For example, `add` can appear in:

```text
nm
objdump
```

but not in:

```text
strace
```

because `add` is a function in the program, not a system call.

---

# Part 23 — Only now use `make`

After you have manually built the programs, go back to some of the directories.

Remove the generated build files where appropriate.

For example:

```sh
rm -f *.o exit
```

Read the Makefile again:

```sh
cat makefile
```

Now run:

```sh
make
```

Watch what it prints.

You should recognize the commands.

They are the same commands you previously typed yourself.

For example:

```text
as -o exit.o exit.s
ld -o exit exit.o
```

or:

```text
gcc -c main.c
gcc -c add.s
gcc -o example main.o add.o
```

This is the important lesson:

**`make` is not an assembler, compiler or linker.**

`make` decides which commands need to be executed.

Because C compiler can't figure out which are the source file dependencies.

C language has no modules. So no module hierarchy. Therefore we need some way of describing the build.

The actual work is performed by programs such as:

```text
as
cc
gcc
fpc
ld
```

You already know what those commands do because you executed them manually first.

---

# Part 24 — Think about the complete path

For assembly:

```text
assembly source
      |
      | assembler
      v
 object file
      |
      | linker
      v
 executable
```

For C:

```text
C source
   |
   | compiler
   v
object file
   |
   | linker
   v
executable
```

For the mixed example:

```text
main.c                    add.s
   |                        |
   | compiler               | assembler
   v                        v
main.o                    add.o
   \                        /
    \                      /
     +------- linker ------+
               |
               v
            example
```

And after the executable exists:

```text
             executable
            /     |      \
           /      |       \
          v       v        v
         nm    objdump     ldd
                  |
                  |
               execute
                  |
                  v
               strace
                  |
                  v
            system calls
                  |
                  v
             Linux kernel
```

---
DO NOT submit binaries: object files or executables. 

DO NOT do `git add *` or `git add .`.

# Files you must submit

Keep the `ldd` results for every executable.

Depending on the directory, these may be named:

```text
ldd.txt
ldd-dynamic.txt
ldd-static.txt
ldd-smart.txt
```

Keep every `strace` result:

```text
strace.txt
strace-dynamic.txt
strace-static.txt
strace-smart.txt
```

Keep the disassembly of every executable:

```text
disassembly.txt
disassembly-dynamic.txt
disassembly-static.txt
disassembly-smart.txt
```

You do not need to use exactly these filenames where several executables exist, but the filenames must make it obvious which executable each result belongs to.

---

# Submit your work with Git

Before adding anything, look at your repository:

```sh
git status
```

Read the output.

Then add your work:

```sh
git add '*.txt'
```

Look again:

```sh
git status
```

Make sure the files you were asked to submit are present.

Commit:

```sh
git commit  -a -m "complete object files and system calls lab"
```

Then push the commit to **your own repository created from the course template**:

```sh
git push
```

Check that the push succeeds.

Your work is submitted only when your commit is present in your own remote repository in our organization.

---

# What you should understand after this lab

The purpose of this lab was not to teach you how to print:

```text
Hello, world
```

The purpose was to expose layers which are usually hidden.

You started with source code.

You manually created object files.

You stopped and inspected those object files before linking them.

You then manually linked them into executables.

You inspected the executable machine code.

You checked its library dependencies.

You watched its system calls while it ran.

Finally, you let `make` repeat commands which you already understood.

The important path is:

```text
source
   |
   v
compiler / assembler
   |
   v
object file
   |
   v
linker
   |
   v
executable
   |
   +----> nm       -> symbols
   |
   +----> objdump  -> machine instructions
   |
   +----> ldd      -> shared-library dependencies
   |
   +----> execute
             |
             v
           strace  -> system calls
             |
             v
        Linux kernel
```

And the mixed C/assembly example demonstrates another fundamental idea:

```text
main.o needs add
add.o provides add
linker connects them
```

Different source languages can produce object files which are linked together.

Finally:

```text
function call != system call
```

`add()` executes inside the process.

`write()` crosses into the Linux kernel.

That is why you can see `add` in the symbols and disassembly, but not in `strace`.

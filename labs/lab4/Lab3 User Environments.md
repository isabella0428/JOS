## Lab3 User Environments

This lab is divided into two parts, user environments and exception handling and Page Faults, Breakpoints Exceptions, and System Calls.



#### Part A: User Environments and Exception Handling

**Exercise 1.** Modify `mem_init()` in `kern/pmap.c` to allocate and map the `envs` array. This array consists of exactly `NENV` instances of the `Env` structure allocated much like how you allocated the `pages` array. Also like the `pages` array, the memory backing `envs` should also be mapped user read-only at `UENVS` (defined in `inc/memlayout.h`) so user processes can read from this array.

You should run your code and make sure `check_kern_pgdir()` succeeds.

##### Answer

This exercise is much like exercise 1 in lab2.

Similarily, we just allocate an array `envs` to hold the pointers to each `Env` structure and map the `envs` to user address space.

```c
void
mem_init(void)
{
	........
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = boot_alloc(NENV * sizeof(struct ENV*));
	.......
	//////////////////////////////////////////////////////////////////////
	// Map the 'envs' array read-only by the user at linear address UENVS
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR((void *)envs), PTE_U | PTE_P);
  .....
}
```



**Exercise 2.** In the file `env.c`, finish coding the following functions:

- `env_init()`

  Initialize all of the `Env` structures in the `envs` array and add them to the `env_free_list`. Also calls `env_init_percpu`, which configures the segmentation hardware with separate segments for privilege level 0 (kernel) and privilege level 3 (user).

- `env_setup_vm()`

  Allocate a page directory for a new environment and initialize the kernel portion of the new environment's address space.

- `region_alloc()`

  Allocates and maps physical memory for an environment

- `load_icode()`

  You will need to parse an ELF binary image, much like the boot loader already does, and load its contents into the user address space of a new environment.

- `env_create()`

  Allocate an environment with `env_alloc` and call `load_icode` to load an ELF binary into it.

- `env_run()`

  Start a given environment running in user mode.

As you write these functions, you might find the new cprintf verb `%e` useful -- it prints a description corresponding to an error code. For example,

```
	r = -E_NO_MEM;
	panic("env_alloc: %e", r);
```

will panic with the message "env_alloc: out of memory".



##### Answer:

Here we should inplement the critical functions of environment creations.

1. env_init

Initialization environments is similar to initialization of pages. 

Just link the environments tail by tail. Make sure that env[0] is at the head of the list.

Then we call `env_init_percpu` to load GDT and intializes the segment registers.

```c
void
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	// Be sure to let envs[0] at the head of `env_free_list`
	env_free_list = NULL;

	for(int i = NENV - 1; i >= 0; --i) {
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}

	// Per-CPU part of the initialization
	env_init_percpu();
}
```



2. env_setup_vm

In this function, we copy the kernel memory into our environment address space.

We can accoplish this by simply allocating a continuous space of size PGSIZE and copying the kernel page table to the environment page table.

In JOS, there is no separate kernel memory. We copy kernel memory each time when we create a new process.

```c
static int
env_setup_vm(struct Env *e)
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
		
  	p->pp_ref++;
	// Allocate a page for this environment's page directory
	e->env_pgdir = (pde_t *)page2kva(p);
	// Map kernel memory into environment's page directory
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;

	return 0;
}
```



4. region_alloc

Allocate len bytes of memory to our environment.

We accomplish this by allocating pages and inserting them to the virtual address starting from va.

```c
static void
region_alloc(struct Env * e, void *va, size_t len)
{
	char *start_address = ROUNDDOWN(va, PGSIZE);
	char *end_address = ROUNDUP(len, PGSIZE) + start_address;
	char *current_address = start_address;
	struct PageInfo *p;

	while (current_address < end_address)
	{
		if (!(p = page_alloc(0)))
			panic("Region Allocation for env %d failed", e->env_id);
		page_insert(e->env_pgdir, p, current_address, PTE_U | PTE_W);
		current_address += PGSIZE;
	}
}
```



5. load_icode

Since we haven't set up a file system yet, here we load the elf binary into our system instead. Like bootloader in `main.c`, we load each program segment into our environment.

Remember to change `cr3` when reading segments.

```c
static void
load_icode(struct Env *e, uint8_t *binary)
{
	struct Proghdr *ph, *eph;
	struct PageInfo *stack;
	struct Elf *ELFHDR = (struct Elf *)binary;
	if (ELFHDR->e_magic != ELF_MAGIC)
		panic("It is not a ELF format file!");

	ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff);

	eph = ph + ELFHDR->e_phnum;

	// Load CR3 to this environment's page directory
	lcr3(PADDR(e->env_pgdir));

	for (; ph < eph; ph++)
	{
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		region_alloc(e, (void *)ph->p_va, ph->p_memsz);
		memset((void *)ph->p_va, 0, ph->p_memsz);
		memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
	}

	// Make sure that the environment sta·rts executing there
	e->env_tf.tf_eip = ELFHDR->e_entry;

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	lcr3(PADDR(kern_pgdir));
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
}
```



4. env_create

In this function, we just combine the `env_alloc` and `load_icode` functions. Allocate a new environment and read program segments into it.

```c
void
env_create(uint8_t *binary, enum EnvType type)
{
	// LAB 3: Your code here.
	struct Env *env;
	int result;

	// Allocates a new env with env_alloc
	result = env_alloc(&env, 0);
	if (result == -E_NO_FREE_ENV)
		panic("env_alloc: %e", result);

	if (result == -E_NO_MEM)
		panic("env_alloc: %e", result);

	//Loads the named elf binary into it with load_icode
	load_icode(env, binary);

	//Set the newly allocated env's type
	env->env_type = type;
}
```



5. env_run

Switch environments and set the new environment's registers.

```c
void
	env_run(struct Env * e)
{
	if (curenv != NULL && curenv->env_status == ENV_RUNNING)
		curenv->env_type = ENV_RUNNABLE;

	// Set 'curenv' to the new environment
	curenv = e;

	// Set its status to ENV_RUNNING,
	curenv->env_status = ENV_RUNNING;

	// Update its 'env_runs' counter
	curenv->env_runs++;

	// Use lcr3() to switch to its address space
	lcr3(PADDR(curenv->env_pgdir));

	// Use env_pop_tf() to restore the environment's
	//	   registers and drop into user mode in the
	//	   environment.

	env_pop_tf(&curenv->env_tf);

	// panic("env_run not yet implemented");
}
```



**Evaluation** Use make qemu-gdb and set a GDB breakpoint at `env_pop_tf`, which should be the last function you hit before actually entering user mode. Single step through this function using si; the processor should enter user mode after the `iret` instruction. You should then see the first instruction in the user environment's executable, which is the `cmpl` instruction at the label `start` in `lib/entry.S`. Now use b *0x... to set a breakpoint at the `int $0x30` in `sys_cputs()` in `hello` (see `obj/user/hello.asm` for the user-space address). This `int` is the system call to display a character to the console. If you cannot execute as far as the `int`, then something is wrong with your address space setup or program loading code; go back and fix it before continuing.

##### Test

Enter gdb, see if we can successfully execute to the `int $0x30 ` instructions defined in user environment function `sys_calls`

```
(gdb) b env_pop_tf
Breakpoint 1 at 0xf0102e61: file kern/env.c, line 485.
(gdb) c
Continuing.
The target architecture is assumed to be i386
=> 0xf0102e61 <env_pop_tf>:     push   %ebp

Breakpoint 1, env_pop_tf (tf=0xf01f2000) at kern/env.c:485
485     {
(gdb) si
=> 0xf0102e62 <env_pop_tf+1>:   mov    %esp,%ebp
0xf0102e62      485     {
(gdb) si
=> 0xf0102e64 <env_pop_tf+3>:   sub    $0xc,%esp
0xf0102e64      485     {
(gdb) si
=> 0xf0102e67 <env_pop_tf+6>:   mov    0x8(%ebp),%esp
486             asm volatile(
(gdb) si
=> 0xf0102e6a <env_pop_tf+9>:   popa   
0xf0102e6a      486             asm volatile(
(gdb) si
=> 0xf0102e6b <env_pop_tf+10>:  pop    %es
0xf0102e6b in env_pop_tf (
    tf=<error reading variable: Unknown argument list address for `tf'.>) at kern/env.c:486
486             asm volatile(
(gdb) si
=> 0xf0102e6c <env_pop_tf+11>:  pop    %ds
0xf0102e6c      486             asm volatile(
(gdb) si
=> 0xf0102e6d <env_pop_tf+12>:  add    $0x8,%esp
0xf0102e6d      486             asm volatile(
(gdb) si
=> 0xf0102e70 <env_pop_tf+15>:  iret   
0xf0102e70      486             asm volatile(
(gdb) info register
eax            0x0                 0
ecx            0x0                 0
edx            0x0                 0
ebx            0x0                 0
esp            0xf01f2030          0xf01f2030
ebp            0x0                 0x0
esi            0x0                 0
edi            0x0                 0
eip            0xf0102e70          0xf0102e70 <env_pop_tf+15>
eflags         0x96                [ PF AF SF ]
cs             0x8                 8
ss             0x10                16
ds             0x23                35
es             0x23                35
fs             0x23                35
gs             0x23                35
(gdb) si
=> 0x800020:    cmp    $0xeebfe000,%esp			//first instruction we execute in entry.S
0x00800020 in ?? ()													//See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp

(gdb) info register
eax            0x0                 0
ecx            0x0                 0
edx            0x0                 0
ebx            0x0                 0
esp            0xeebfe000          0xeebfe000
ebp            0x0                 0x0
esi            0x0                 0
edi            0x0                 0
eip            0x800020            0x800020
eflags         0x2                 [ ]
cs             0x1b                27
ss             0x23                35
ds             0x23                35
es             0x23                35
fs             0x23                35
gs             0x23                35
```

Here we can see the register value are changed after we enter the user mode.

The code segment register's value correspond to the definition in function `env_alloc`

```c
int
env_alloc(struct Env * *newenv_store, envid_t parent_id)
{
	............
	e->env_tf.tf_ds = GD_UD | 3;
	e->env_tf.tf_es = GD_UD | 3;
	e->env_tf.tf_ss = GD_UD | 3;
	e->env_tf.tf_esp = USTACKTOP;
	e->env_tf.tf_cs = GD_UT | 3;
	...........
}
```

Then we continue executing. 

Finally we are able to execute to this instruction, which means we did it :-D

```
(gdb) si
=> 0x800a0a:    int    $0x30
0x00800a0a in ?? ()
```



#### Handling Interrupts and Exceptions

**Exercise 3.** Read [Chapter 9, Exceptions and Interrupts](https://pdos.csail.mit.edu/6.828/2018/readings/i386/c09.htm) in the [80386 Programmer's Manual](https://pdos.csail.mit.edu/6.828/2018/readings/i386/toc.htm) (or Chapter 5 of the [IA-32 Developer's Manual](https://pdos.csail.mit.edu/6.828/2018/readings/ia32/IA32-3A.pdf)), if you haven't already.

##### Answer

This link above provides us with the basic background knowledge about Interruptions and Exceptions needed in this lab. Reading it helps a lot for following exercises:-D



**Exercise 4.** Edit `trapentry.S` and `trap.c` and implement the features described above. The macros `TRAPHANDLER` and `TRAPHANDLER_NOEC` in `trapentry.S` should help you, as well as the T_* defines in `inc/trap.h`. You will need to add an entry point in `trapentry.S` (using those macros) for each trap defined in `inc/trap.h`, and you'll have to provide _alltraps` which the `TRAPHANDLER` macros refer to. You will also need to modify `trap_init()` to initialize the `idt` to point to each of these entry points defined in `trapentry.S`; the `SETGATE` macro will be helpful here.

Your `_alltraps` should:

1. push values to make the stack look like a struct Trapframe
2. load `GD_KD` into `%ds` and `%es`
3. `pushl %esp` to pass a pointer to the Trapframe as an argument to trap()
4. `call trap` (can `trap` ever return?)

Consider using the `pushal` instruction; it fits nicely with the layout of the `struct Trapframe`.

Test your trap handling code using some of the test programs in the `user` directory that cause exceptions before making any system calls, such as `user/divzero`. You should be able to get make grade to succeed on the `divzero`, `softint`, and `badsegment` tests at this point.

##### Answer:

First let's look at `trap.c`. Here we need to initializes the interrupt handler functions and insert them into the interrupt descriptor table. Just some trivial codes.

```c
oid
trap_init(void)
{
	extern struct Segdesc gdt[];

	// Define handler functions
	void t_divide();
	void t_debug();
	void t_nmi();
	void t_brkpt();
	void t_oflow();
	void t_bound();
	void t_illop();
	void t_device();
	void t_dblflt();
	void t_tss();
	void t_segnp();
	void t_stack();
	void t_gpflt();
	void t_pgflt();
	void t_fperr();
	void t_align();
	void t_mchk();
	void t_simderr();
	void t_syscall();

  // Add IDT's interrupt gates and trap gates
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
	SETGATE(idt[T_BRKPT], 1, GD_KT, t_brkpt, 0);
	SETGATE(idt[T_OFLOW], 1, GD_KT, t_oflow, 0);
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);

	SETGATE(idt[T_SYSCALL], 1, GD_KT, t_syscall, 3);

	// Per-CPU setup 
	trap_init_percpu();
}
```

Then we need to add interrupt entry into `trapentry.S`

There are two macros available in `trapentry.S`, which defines a globally visible function for handling a trap. If the trap has no error code, we push a zero in order to keep it in the same form of `Trapframe`.

According to the [interrupt info](https://pdos.csail.mit.edu/6.828/2018/readings/i386/s09_09.htm) given by the lab materials, we create handler functions for each trap.

```assembly
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE);		// 0  divide error
TRAPHANDLER_NOEC(t_debug,  T_DEBUG);		// 1  debug exception
TRAPHANDLER_NOEC(t_nmi, T_NMI);					// 2  non-maskable interrupt
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT);			// 3  breakpoint
TRAPHANDLER_NOEC(t_oflow, T_OFLOW);			// 4  overflow
TRAPHANDLER_NOEC(t_bound, T_BOUND);			// 5  bounds check	
TRAPHANDLER_NOEC(t_illop, T_ILLOP);			// 6  illegal opcode
TRAPHANDLER_NOEC(t_device, T_DEVICE);		// 7  device not available

TRAPHANDLER(t_dblflt, T_DBLFLT);				// 8  double fault
TRAPHANDLER(t_tss, T_TSS);							// 10 invalid task switch segment
TRAPHANDLER(t_segnp, T_SEGNP);					// 11 segment not present
TRAPHANDLER(t_stack, T_STACK);					// 12 stack exception
TRAPHANDLER(t_gpflt, T_GPFLT);					// 13 general protection fault
TRAPHANDLER(t_pgflt, T_PGFLT);					// 14 page fault

TRAPHANDLER_NOEC(t_fperr, T_FPERR);			// 16 floating point error

TRAPHANDLER(t_align, T_ALIGN);					// 17 aligment check

TRAPHANDLER_NOEC(t_mchk, T_MCHK);				// 18 machine check
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR);	// 19 SIMD floating point error
TRAPHANDLER_NOEC(t_syscall, T_SYSCALL);	// 48 SIMD floating point error
```

According to the Trapframe definition, we need to push the values from bottom to the top, from `esp` to `tf_regs`. In the macros, we only push to `trap_no`. So we still need to push `es` and `ds`.Then we use `pushal` to push all general registers.

Then we load kernel data into `ds` and `es` to switch to kernel mode. Since the definition of trap functions is `void trap(struct Trapframe *tf)`, we also need to push stack pointer as parameters. Finally we call `trap `to handle the traps.

```assembly
_alltraps: 
	// 1. push values to make the stack look like a struct Trapframe
    pushl %ds
    pushl %es
    pushal

	// 2. load GD_KD into %ds and %es
    movw $GD_KD, %ax
    movw %ax, %ds
    movw %ax, %es

	// 3. pushl %esp to pass a pointer to the Trapframe as an argument to trap()
	pushl %esp

	// 4. call trap
    call trap
```



**Questions**

1. What is the purpose of having an individual handler function for each exception/interrupt? (i.e., if all exceptions/interrupts were delivered to the same handler, what feature that exists in the current implementation could not be provided?)

   ##### Answer:

   If we handle all exceptions or interrupts with an individual handler function, we will need to use a lot of condition instructions in our functions and it is hard to realize. What's more, they have different return sentences. For example, a `divdie zero` function may not return, while an `system call` will return back to the user environment after the system function call. 



2. Did you have to do anything to make the `user/softint` program behave correctly? The grade script expects it to produce a general protection fault (trap 13), but `softint`'s code says `int $14`. *Why* should this produce interrupt vector 13? What happens if the kernel actually allows `softint`'s `int $14` instruction to invoke the kernel's page fault handler (which is interrupt vector 14)?

   ##### Answer: 

   Let's look at the definitions in `softint` and `grade-lab3`

   ```c
   void
   umain(int argc, char **argv)
   {
   	asm volatile("int $14");	// page fault
   }
   ```

   ```c
   @test(10)
   def test_softint():
       r.user_test("softint")
       r.match('Welcome to the JOS kernel monitor!',
               'Incoming TRAP frame at 0xefffffbc',
               'TRAP frame at 0xf.......',
               '  trap 0x0000000d General Protection',
               '  eip  0x008.....',
               '  ss   0x----0023',
               '.00001000. free env 0000100')
   ```

   Since we are still in user mode when we call `int $14 ` and our priviledge level is 3, however `int` is a system call, which priviledge level is 0. Then OS will handle this exception in kernel mode. So it triggers the fault general protection error instead of page fault error. 

   If system calls are allowed to be called from user environment, it will cause huge seurity issues and the misuse of the user will probably let the whole OS breakdown.



### Part B: Page Faults, Breakpoints Exceptions, and System Calls

#### Handling Page Faults

page fault is an important exception that we are gonna handle. When the processor takes a page fault, it stores the linear address that caused the fault in a special processor control register, CR2. 



**Exercise 5.** Modify `trap_dispatch()` to dispatch page fault exceptions to `page_fault_handler()`. You should now be able to get make grade to succeed on the `faultread`, `faultreadkernel`, `faultwrite`, and `faultwritekernel` tests. If any of them don't work, figure out why and fix them. Remember that you can boot JOS into a particular user program using make run-*x* or make run-*x*-nox. For instance, make run-hello-nox runs the *hello* user program.

##### Answer

This one is simple. Just check if `tf` 's `trap_no` is 14, call `page_fault_handler` to handle the fault.

```c
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == 14) {
    page_fault_handler(tf);
    return;
  }

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
	if (tf->tf_cs == GD_KT)
		panic("unhandled trap in kernel");
	else {
		env_destroy(curenv);
		return;
	}
}
```



**Exercise 6.** Modify `trap_dispatch()` to make breakpoint exceptions invoke the kernel monitor. You should now be able to get make grade to succeed on the `breakpoint` test.

This is just like the previous exercise.  Just need to make sure that u set the priviledge of breakpoint execption to 3. Otherwise it will cause general protection error instead of breakpoint execption.

```c
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	// Check if it is a page fault
	if(tf->tf_trapno == 14) {
    	page_fault_handler(tf);
    	return;
  }

	// Check if it is a breakpoint exception
	if(tf->tf_trapno == 3) {
    monitor(tf);
    return;
  }

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
	if (tf->tf_cs == GD_KT)
		panic("unhandled trap in kernel");
	else {
		env_destroy(curenv);
		return;
	}
}
```



**Questions**

1. The break point test case will either generate a break point exception or a general protection fault depending on how you initialized the break point entry in the IDT (i.e., your call to `SETGATE` from `trap_init`). Why? How do you need to set it up in order to get the breakpoint exception to work as specified above and what incorrect setup would cause it to trigger a general protection fault?

   ##### Answer:

   As mentioned above, we need to call `SETGATE` to set the priviledge of `breakpoint exception` to be 3 instead of 0. So that the user can cause the breakpoint exception from user mode without causing general protection fault.

   

2. What do you think is the point of these mechanisms, particularly in light of what the `user/softint` test program does?

   ##### Answer

   We use interrupt descriptor table to set priviledge level of each interrupts so that we can distinguish different kinds of excptions and faults and handle them properly. If the fault cannot be caused when we are in the user mode, the protection mechanisum will work and protect the illegal operation by triggering the general protection fault.



#### System Call

**Exercise 7.** Add a handler in the kernel for interrupt vector `T_SYSCALL`. You will have to edit `kern/trapentry.S` and `kern/trap.c`'s `trap_init()`. You also need to change `trap_dispatch()` to handle the system call interrupt by calling `syscall()` (defined in `kern/syscall.c`) with the appropriate arguments, and then arranging for the return value to be passed back to the user process in `%eax`. Finally, you need to implement `syscall()` in `kern/syscall.c`. Make sure `syscall()` returns `-E_INVAL` if the system call number is invalid. You should read and understand `lib/syscall.c` (especially the inline assembly routine) in order to confirm your understanding of the system call interface. Handle all the system calls listed in `inc/syscall.h` by invoking the corresponding kernel function for each call.

Run the `user/hello` program under your kernel (make run-hello). It should print "`hello, world`" on the console and then cause a page fault in user mode. If this does not happen, it probably means your system call handler isn't quite right. You should also now be able to get make grade to succeed on the `testbss` test.

##### Answer:

1. Edit `trapentry.S` and `trap.c` to add gate of IDT and entry points for `int 0x30`. 

```assembly
// trayentry.S
TRAPHANDLER_NOEC(t_syscall, T_SYSCALL);	// 19 SIMD floating point error
```

```c
// trap.c: trap()
void trap_init(void) {
  .................
	void t_syscall();
  .................
	//Remember to set the priviledge to be 3 so that it can be triggered in user mode
	SETGATE(idt[T_SYSCALL], 1, GD_KT, t_syscall, 3); 
}
```

2. Modify `trap_dispatch()` to call `syscall` handler in`kern/syscall.c`.

In addition to trap numbers, we also need system call types and parameters to deal with it. According to the descriptions above, system call numbers and its parameters are stored in the general registers in trapframe, `eax`, `edx`, `ecx`, `ebx`, `edi` and `esi`. 

We should first determine if the system call number is implemented in system calls. 

As defined in `inc/syscall.h`, there are five types in total. However, `kern/syscall.c` only implement the first four. So we will continue execute `syscall` in kernel mode only if the system number stored in `%eax` ranges from 0 to 4.

```c
enum {
	SYS_cputs = 0,
	SYS_cgetc,
	SYS_getenvid,
	SYS_env_destroy,
	NSYSCALLS
};
```



Then we call the kernel version `syscall` to handle `syscall trap` . In order to pass the return value of `syscall` to user mode, we just need to store it in `tf` since `tf`  's  register values will be popped out after we return back to user mode. 

```c
static void trap_dispatch(struct Trapframe *tf) {
		if(tf->tf_trapno == T_SYSCALL) {
		struct PushRegs regs = tf->tf_regs;
		if (regs.reg_eax >= NSYSCALLS)
			return;
		result = syscall(regs.reg_eax, regs.reg_edx, regs.reg_ecx,
							regs.reg_ebx, regs.reg_edi, regs.reg_esi);
		(tf->tf_regs).reg_eax = result;
		return;
	}
}
```

4. Modify kernel version `syscall` to call the kernel functions

```c
// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((const char*)a1, (size_t)a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
		case SYS_env_destroy:
			return sys_env_destroy((envid_t)a1);
		default:
			return -E_INVAL;
	}
}
```



#### User mode start-up

**Exercise 8.** Add the required code to the user library, then boot your kernel. You should see `user/hello` print "`hello, world`" and then print "`i am environment 00001000`". `user/hello` then attempts to "exit" by calling `sys_env_destroy()` (see `lib/libmain.c` and `lib/exit.c`). Since the kernel currently only supports one user environment, it should report that it has destroyed the only environment and then drop into the kernel monitor. You should be able to get make grade to succeed on the `hello` test.

##### Answer

To answer this question, let's first look at the definition of `envid_t` in `inc/env.h`.

```c
+1+---------------21-----------------+--------10--------+
|0|          Uniqueifier             |   Environment    |
| |                                  |      Index       |
+------------------------------------+------------------+
                                      \--- ENVX(eid) --/
```

There are 32 bits in total, low 10 bits for environment index, which is also the index of `envs` array and the high 21 bits for environment uniqueifiers and the highest sign bit to signal errors(if the highest bit is one, it means something is going wrong.) 

We need the uniqueifiers because we can create the same environment with same environment index at different times, so we need something other than the environment index to signal this point.

We can use macros defined in `inc/env.h` to get the environment index.

```c
#define ENVX(envid)		((envid) & (NENV - 1))
```

It gets us low 10 bits of the envid.

Then we use the environment index to help us find the correct address in `envs`.

```c
void
libmain(int argc, char **argv)
{
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	struct Env curenv = envs[ENVX(sys_getenvid())];
	thisenv = &curenv;

	// save the name of the program so that panic() can use it
	if (argc > 0)
		binaryname = argv[0];
	
	// call user main routine
	umain(argc, argv);

	// exit gracefully
	exit();
}
```



#### Page faults and memory protection

**Exercise 9.** Change `kern/trap.c` to panic if a page fault happens in kernel mode.

Hint: to determine whether a fault happened in user mode or in kernel mode, check the low bits of the `tf_cs`.

Read `user_mem_assert` in `kern/pmap.c` and implement `user_mem_check` in that same file.

Change `kern/syscall.c` to sanity check arguments to system calls.

Boot your kernel, running `user/buggyhello`. The environment should be destroyed, and the kernel should *not* panic. You should see:

```
	[00001000] user_mem_check assertion failure for va 00000001
	[00001000] free env 00001000
	Destroyed the only environment - nothing more to do!
	
```

Finally, change `debuginfo_eip` in `kern/kdebug.c` to call `user_mem_check` on `usd`, `stabs`, and `stabstr`. If you now run `user/breakpoint`, you should be able to run backtrace from the kernel monitor and see the backtrace traverse into `lib/libmain.c` before the kernel panics with a page fault. What causes this page fault? You don't need to fix it, but you should understand why it happens.

##### Answer

1. Change `kern/trap.c` to panic if a page fault happens in kernel mode

   If `tf->tf_cs` is equal to `UD_KT`, then it is in kernel mode

```c
void
page_fault_handler(struct Trapframe *tf)
{
	........
	if (tf->tf_cs == GD_KT) {
		panic("Kernel Page Fault!");
	}
	........
}
```



2. implement `user_mem_check`

This function is intended to check if the address is accessible with given permission.

It is much like the previous page operations. We can use `pfdir_walk` implemented in lab2 to get the page directory entry of the given virtual address. Then we find out if it is a accessible by user.

A virtual address is accessibleif it meets all three requirements:

* Page entry of `va` is not NULL(the virtual address is allocated)

* `va` is below the user address space limit `ULIM`
* Page entry of `va` contains the permission we require in `perm`

When there is something wrong with the pages, we need to return the first address of the illegal address space. Remember to return `va` and `va + len` when we fail in the first or last page.

```c
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	const char* start_addr = ROUNDDOWN(va, PGSIZE);
	const char* end_addr = ROUNDUP(va + len, PGSIZE);

	for(const char* addr = start_addr; addr <= end_addr; addr += PGSIZE) {
		pte_t* pg_entry = pgdir_walk(curenv->env_pgdir, addr, 0);

		// A user program can access a virtual address
		// (1) the address is below ULIM
		// (2) the page table gives it permission.
		
		if (pg_entry == NULL || addr > (const char *)ULIM 
			&& (*pg_entry && 3) < perm) 
		{
			user_mem_check_addr = (uintptr_t)addr;
			// Notice that the first erroneous address is va
			if(addr == start_addr)
				user_mem_check_addr = (uintptr_t)va;
			// Notice that the first erroneous address is (va+len)
			else if (addr + PGSIZE == end_addr) {
				user_mem_check_addr = (uintptr_t)va;
			}
			return -E_FAULT;
		}
	}
	return 0;
}
```



3. Change `kern/syscall.c` to sanity check arguments to system calls

Check if the virtual address from `a1` to `a1+a2` is accessible to the user.

```c
// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");
	switch (syscallno) {
		case SYS_cputs:
			// Check whether parameters are valid
			user_mem_assert(curenv, (void *)a1, (size_t)a2, PTE_P);
			sys_cputs((const char*)a1, (size_t)a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
		case SYS_env_destroy:
			// Check whether parameters are valid
			// user_mem_assert(curenv, (void *)a1, (size_t)PGSIZE, PTE_U);
			sys_env_destroy((envid_t)a1);
			return 0;
		default:
			return -E_INVAL;
	}
}
```

Okay, now that we finish all the codes required in this exercise, it's time to test it.

Let's run `make-buggyhello-nox` in terminal.

```
[00000000] new env 00001000
Incoming TRAP frame at 0xefffffbc
Incoming TRAP frame at 0xefffffbc
[00001000] user_mem_check assertion failure for va 00000001
[00001000] free env 00001000
Destroyed the only environment - nothing more to do!
```

It shows the same info given by the lab website, which means the codes we just written are correct :-D



4. Change s in `kern/kdebug.c` to call `user_mem_check` on `usd`, `stabs`, and `stabstr`

Here we call `user_mem_check` to check if `usd`, `stabs`, `stabstr` are accessible by the users.

```c
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
		..............
		user_mem_check(curenv, usd, stab_end - stabs, PTE_U);
		user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U);
		..............
		for(struct Stab* st = (struct Stab*)stabs; st <= stab_end; ++st) {
			user_mem_check(curenv, (void *)st, sizeof(struct Stab), PTE_U);
		}
		.............
}
```



Okay now we finish this exercise 9 :-D

When we run `make run-breakpoint-nox` in the terminal, these show up

```
(base) ➜  lab3 git:(master) ✗ make run-breakpoint-nox
	................
	TRAP frame at 0xf01f4000
    edi  0xeebfdfd8
    esi  0xeec00060
    ebp  0xeebfdff0
    oesp 0xefffffdc
    ebx  0x00000000
    edx  0x00000000
    ecx  0x00000000
    eax  0xeebfdf78
    es   0x----0023
    ds   0x----0023
    trap 0x00000003 Breakpoint
    err  0x00000000
    eip  0x00800034
    cs   0x----001b
    flag 0x00000082
    esp  0xeebfdf64
  ...................
```

It is clear to see that it has triggered the `breakpoint trap`.

However, when we then input `backtrace` in `qemu` terminal, something "weird" happens.

```
K> backtrace
Incoming TRAP frame at 0xeffffee8
kernel panic at kern/trap.c:274: Kernel Page Fault!
```

It shows kernel page fault this time. 

Well, it is not hard to understand. Let's look at `mon_backtrace`'s definition.

```c
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	..........
  //Print debuging info
  debuginfo_eip(eip, &info);
  ..........
}
```

Function `backtrace` calls our new function `debuginfo_eip`, which will check if `usd`, `stabs`, `stabstr` are accessible by the users. If they are inaccessible, it will cause kernel page fault :-D



**Exercise 10.** Boot your kernel, running `user/evilhello`. The environment should be destroyed, and the kernel should not panic. You should see:

```
	[00000000] new env 00001000
	...
	[00001000] user_mem_check assertion failure for va f010000c
	[00001000] free env 00001000
```

Let's try out this test.

Run `make run-evilhello-nox` in terminal.

```c
...........................
[00000000] new env 00001000
Incoming TRAP frame at 0xefffffbc
Incoming TRAP frame at 0xefffffbc
[00001000] user_mem_check assertion failure for va f010000c
[00001000] free env 00001000
...........................
```

It is gladly the same with the given output message :-D



### Final Test with 'make grade'

```
divzero: OK (1.2s) 
softint: OK (1.3s) 
badsegment: OK (1.8s) 
Part A score: 30/30

faultread: OK (1.8s) 
faultreadkernel: OK (1.0s) 
faultwrite: OK (1.4s) 
faultwritekernel: OK (1.8s) 
breakpoint: OK (1.8s) 
testbss: OK (1.1s) 
hello: OK (1.3s) 
buggyhello: OK (1.9s) 
buggyhello2: OK (1.7s) 
evilhello: <gradelib.Runner object at 0x10b3744a8>
OK (0.9s) 
Part B score: 50/50

Score: 80/80
```

That't it for the lab3. See u at next lab :)